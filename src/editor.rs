use chrono::Local;
use neovim_lib::neovim_api::Buffer;
use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApi, Value};
use regex::Regex;
use result::{error, Result};
use std::fmt;
use std::net::SocketAddr;
use std::str::FromStr;
use std::sync::{mpsc, Arc, Mutex, MutexGuard};

static LOG_BUFFER_NAME: &str = "/tmp/conjure.cljc";

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
    ParseError { name: String, err: String },

    #[fail(display = "unknown request name: {}", name)]
    UnknownRequestName { name: String },
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
                &buf.get_name(&mut nvim).unwrap_or_else(|_| {
                    warn!("Couldn't get buffer name");
                    "".to_owned()
                }) == LOG_BUFFER_NAME
            }).map(|buf| buf.clone());

        Ok(buf)
    }

    pub fn display_or_create_log_window(&mut self) -> Result<()> {
        self.command(&format!("10new {}", LOG_BUFFER_NAME))?;
        self.command("setlocal wfh")?;
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

    pub fn log_writelns(&mut self, tag: &str, lines: &[String]) {
        let timestamp = Local::now().format("%T");
        let mut lines = lines.to_vec();
        lines.insert(0, format!(";; {} @ {}", tag, timestamp));
        lines.push("".to_owned());

        if let Err(msg) = self.find_or_create_log_buf().and_then(|buf| {
            let mut nvim = self.nvim()?;

            buf.set_lines(&mut nvim, 0, 0, false, lines).map_err(error)
        }) {
            self.err_writeln(&format!("Failed to log: {}", msg))
        }
    }

    pub fn log_writeln(&mut self, tag: &str, line: String) {
        self.log_writelns(tag, &[line]);
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
    },
    Disconnect {
        key: String,
    },
    Eval {
        code: String,
        path: String,
    },
    Doc {
        name: String,
        path: String,
    },
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
        })?.as_str()
        .ok_or_else(|| {
            error(Error::ExpectedString {
                name: name.to_owned(),
            })
        })?.parse()
        .map_err(|err| {
            error(Error::ParseError {
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

                Event::Connect { key, addr, expr }
            }
            "disconnect" => {
                let key = parse_arg(&args, 0, "key")?;
                Event::Disconnect { key }
            }
            "eval" => {
                let code = parse_arg(&args, 0, "code")?;
                let path = parse_arg(&args, 1, "path")?;
                Event::Eval { code, path }
            }
            "doc" => {
                let name = parse_arg(&args, 0, "name")?;
                let path = parse_arg(&args, 1, "path")?;
                Event::Doc { name, path }
            }
            _ => {
                return Err(error(Error::UnknownRequestName {
                    name: name.to_owned(),
                }))
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
