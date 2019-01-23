use chrono::Local;
use clojure;
use neovim_lib::neovim_api::Buffer;
use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApi, Value};
use regex::Regex;
use result::{error, Result};
use std::fmt;
use std::net::SocketAddr;
use std::str::FromStr;
use std::sync::{mpsc, Arc, Mutex, MutexGuard};
use util;

static LOG_BUFFER_NAME: &str = "/tmp/conjure.cljc";
static LOG_BUFFER_MAX_LENGTH: i64 = 10_000;

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "could not lock nvim instance")]
    NoNvimLock,

    #[fail(display = "could not create log buffer")]
    LogBufferCreateFailed,

    #[fail(display = "expected argument at position: {}", position)]
    ExpectedArgumentAtPosition { position: usize },

    #[fail(display = "expected `{}` to be a string", name)]
    ExpectedString { name: String },

    #[fail(display = "failed to parse `{}`: {}", name, err)]
    ParseFailed { name: String, err: String },

    #[fail(display = "unknown request name: {}", name)]
    UnknownRequestName { name: String },
}

pub struct Context {
    pub path: String,
    pub ns: Option<String>,
}

impl Context {
    fn new(path: String, ns: Option<String>) -> Self {
        Self { path, ns }
    }
}

#[derive(Clone)]
pub struct Server {
    nvim: Arc<Mutex<Neovim>>,
}

type Sender = mpsc::Sender<Result<Event>>;

impl Server {
    pub fn start(tx: Sender) -> Result<Self> {
        info!("Starting Neovim event loop handler");
        let mut session = Session::new_parent()?;
        session.start_event_loop_handler(Handler::new(tx));

        Ok(Self {
            nvim: Arc::new(Mutex::new(Neovim::new(session))),
        })
    }

    fn nvim(&self) -> Result<MutexGuard<Neovim>> {
        self.nvim.lock().map_err(|_| error(Error::NoNvimLock))
    }

    pub fn command(&mut self, cmd: &str) -> Result<()> {
        let mut nvim = self.nvim()?;

        nvim.command(cmd).map_err(error)
    }

    fn find_log_buf(&mut self) -> Result<Option<Buffer>> {
        let mut nvim = self.nvim()?;

        let bufs = nvim.list_bufs()?;

        let buf = bufs
            .iter()
            .find(|buf| {
                buf.get_name(&mut nvim).unwrap_or_else(|_| {
                    warn!("Couldn't get buffer name");
                    "".to_owned()
                }) == LOG_BUFFER_NAME
            })
            .cloned();

        Ok(buf)
    }

    pub fn display_or_create_log_window(&mut self) -> Result<()> {
        self.command(&format!("10new {}", LOG_BUFFER_NAME))?;
        self.command("setlocal winfixheight")?;
        self.command("setlocal winfixwidth")?;
        self.command("setlocal nowrap")?;
        self.command("setlocal buftype=nofile")?;
        self.command("setlocal bufhidden=hide")?;
        self.command("setlocal noswapfile")?;
        self.command("normal! gg")?;

        Ok(())
    }

    fn find_or_create_log_buf(&mut self) -> Result<Buffer> {
        if let Some(buf) = self.find_log_buf()? {
            return Ok(buf);
        }

        self.display_or_create_log_window()?;

        self.find_log_buf()
            .map(|buf| buf.ok_or_else(|| error(Error::LogBufferCreateFailed)))?
    }

    pub fn err_writeln(&mut self, msg: &str) {
        error!("Error written: {}", msg);

        if let Err(msg) = self
            .nvim()
            .and_then(|mut nvim| nvim.err_writeln(msg).map_err(error))
        {
            error!("Failed to write error line: {}", msg);
        }
    }

    pub fn log_trim(&mut self) {
        if let Err(msg) = self.find_or_create_log_buf().and_then(|buf| {
            let mut nvim = self.nvim()?;
            let count = buf.line_count(&mut nvim)?;

            if count > LOG_BUFFER_MAX_LENGTH {
                buf.set_lines(&mut nvim, LOG_BUFFER_MAX_LENGTH, count, false, vec![])?
            }

            Ok(())
        }) {
            self.err_writeln(&format!("Failed to trim log: {}", msg))
        }
    }

    pub fn scroll_log_windows_to_top(&mut self) {
        if let Err(msg) = self.find_or_create_log_buf().and_then(|buf| {
            {
                let mut nvim = self.nvim()?;
                let wins = nvim.list_wins()?;

                for win in wins.iter() {
                    if win.get_buf(&mut nvim)? == buf {
                        win.set_cursor(&mut nvim, (1, 0))?
                    }
                }
            }

            Ok(())
        }) {
            self.err_writeln(&format!("Failed to scroll log windows to top: {}", msg))
        }
    }

    pub fn log_writelns(&mut self, tag: &str, lines: &[String]) {
        let timestamp = Local::now().format("%T");
        let mut lines = lines.to_vec();
        lines.insert(0, format!(";; {} @ {}", tag, timestamp));
        lines.push("".to_owned());

        if let Err(msg) = self.find_or_create_log_buf().and_then(|buf| {
            let mut nvim = self.nvim()?;
            buf.set_lines(&mut nvim, 0, 0, false, lines)?;
            Ok(())
        }) {
            self.err_writeln(&format!("Failed to log: {}", msg))
        }

        self.log_trim();
        self.scroll_log_windows_to_top();
    }

    pub fn log_writeln(&mut self, tag: &str, line: String) {
        self.log_writelns(tag, &[line]);
    }

    pub fn go_to(&mut self, loc: (String, i64, i64)) -> Result<()> {
        info!("Going to definition {} @ {}:{}", loc.0, loc.1, loc.2);
        self.command(&format!("edit {}", loc.0))?;
        let mut nvim = self.nvim()?;
        let win = nvim.get_current_win()?;
        win.set_cursor(&mut nvim, (loc.1, loc.2))?;
        Ok(())
    }

    pub fn update_completions(&mut self, completions: &[&str]) -> Result<()> {
        let mut nvim = self.nvim()?;
        let completion_values: Vec<Value> = completions
            .iter()
            .map(|x| Value::from(x.to_owned()))
            .collect();
        let buf = nvim.get_current_buf()?;
        buf.set_var(
            &mut nvim,
            "conjure_completions",
            Value::from(completion_values),
        )?;
        Ok(())
    }

    fn try_context(&mut self) -> Result<Context> {
        let mut nvim = self.nvim()?;
        let buf = nvim.get_current_buf()?;
        let path = buf.get_name(&mut nvim)?;
        let head = buf.get_lines(&mut nvim, 0, 100, false)?;

        Ok(Context::new(path, util::ns(&head.join("\n"))))
    }

    pub fn context(&mut self) -> Context {
        match self.try_context() {
            Ok(ctx) => ctx,
            Err(msg) => {
                error!("Failed to create context (returning a default): {}", msg);
                Context::new("unknown.clj".to_owned(), None)
            }
        }
    }
}

#[derive(Debug)]
pub enum Event {
    Quit,
    List,
    ShowLog,
    Connect {
        key: String,
        addr: SocketAddr,
        expr: Regex,
        lang: clojure::Lang,
    },
    Disconnect {
        key: String,
    },
    Eval {
        code: String,
    },
    GoToDefinition {
        name: String,
    },
    UpdateCompletions,
}

impl fmt::Display for Event {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

fn parse_arg<T: FromStr>(args: &[Value], index: usize, name: &str) -> Result<T>
where
    T::Err: fmt::Display,
{
    args.get(index)
        .ok_or_else(|| {
            error(Error::ExpectedArgumentAtPosition {
                position: index + 1,
            })
        })?
        .as_str()
        .ok_or_else(|| {
            error(Error::ExpectedString {
                name: name.to_owned(),
            })
        })?
        .parse()
        .map_err(|err| {
            error(Error::ParseFailed {
                name: name.to_owned(),
                err: format!("{}", err),
            })
        })
}

impl Event {
    fn from(name: &str, args: &[Value]) -> Result<Event> {
        let event = match name {
            "exit" => Event::Quit,
            "list" => Event::List,
            "show_log" => Event::ShowLog,
            "connect" => {
                let key = parse_arg(&args, 0, "key")?;
                let addr = parse_arg(&args, 1, "addr")?;
                let expr = parse_arg(&args, 2, "expr")?;
                let lang = parse_arg(&args, 3, "lang")?;

                Event::Connect {
                    key,
                    addr,
                    expr,
                    lang,
                }
            }
            "disconnect" => {
                let key = parse_arg(&args, 0, "key")?;
                Event::Disconnect { key }
            }
            "eval" => {
                let code = parse_arg(&args, 0, "code")?;
                Event::Eval { code }
            }
            "go_to_definition" => {
                let name = parse_arg(&args, 0, "name")?;
                Event::GoToDefinition { name }
            }
            "update_completions" => Event::UpdateCompletions,
            _ => {
                return Err(error(Error::UnknownRequestName {
                    name: name.to_owned(),
                }));
            }
        };

        Ok(event)
    }
}

struct Handler {
    tx: Sender,
}

impl Handler {
    fn new(tx: Sender) -> Handler {
        Handler { tx }
    }
}

impl neovim_lib::Handler for Handler {
    fn handle_notify(&mut self, name: &str, args: Vec<Value>) {
        let event = Event::from(name, &args);

        if let Err(msg) = self.tx.send(event) {
            error!("Could not send event through channel: {}", msg);
        }
    }
}

impl neovim_lib::RequestHandler for Handler {
    fn handle_request(
        &mut self,
        _name: &str,
        _args: Vec<Value>,
    ) -> std::result::Result<Value, Value> {
        error!("Requests are not supports, use notify");
        Err(Value::Nil)
    }
}
