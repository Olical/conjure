use chrono::Local;
use neovim_lib::neovim_api::Buffer;
use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApi, Value};
use regex::Regex;
use std::fmt;
use std::net::SocketAddr;
use std::str::FromStr;
use std::sync::{mpsc, Arc, Mutex};

// TODO Refactor so this can be shared between threads easily. (channels?)

static LOG_BUFFER_NAME: &str = "/tmp/conjure.cljc";

#[derive(Clone)]
pub struct Server {
    nvim: Arc<Mutex<Neovim>>,
}

type Sender = mpsc::Sender<Result<Event, String>>;

impl Server {
    pub fn start(tx: Sender) -> Result<Self, String> {
        info!("Starting Neovim event loop handler");
        let mut session = Session::new_parent()
            .map_err(|msg| format!("error creating Neovim session: {}", msg))?;
        session.start_event_loop_handler(Handler::new(tx));

        Ok(Self {
            nvim: Arc::new(Mutex::new(Neovim::new(session))),
        })
    }

    pub fn command(&mut self, cmd: &str) -> Result<(), String> {
        self.nvim
            .lock()
            .map_err(|msg| format!("could not get nvim lock: {}", msg))
            .and_then(|mut nvim| {
                nvim.command(cmd)
                    .map_err(|msg| format!("command failed: {}", msg))
            })
    }

    pub fn err_writeln(&mut self, msg: &str) {
        error!("Error written: {}", msg);

        if let Err(msg) = self
            .nvim
            .lock()
            .map_err(|msg| format!("could not get nvim lock: {}", msg))
            .and_then(|mut nvim| {
                nvim.err_writeln(msg)
                    .map_err(|msg| format!("could not write to error output: {}", msg))
            }) {
            error!("Failed to write error line: {}", msg);
        }
    }

    fn find_log_buf(&mut self) -> Result<Option<Buffer>, String> {
        self.nvim
            .lock()
            .map_err(|msg| format!("could not get nvim lock: {}", msg))
            .map(|mut nvim| {
                let bufs = nvim
                    .list_bufs()
                    .map_err(|msg| format!("failed to get buffers: {}", msg))?;

                Ok(bufs
                    .iter()
                    .find(|buf| {
                        &buf.get_name(&mut nvim).unwrap_or_else(|_| {
                            warn!("Couldn't get buffer name");
                            "".to_owned()
                        }) == LOG_BUFFER_NAME
                    }).map(|buf| buf.clone()))
            })?
    }

    pub fn display_or_create_log_window(&mut self) -> Result<(), String> {
        self.command(&format!("10new {}", LOG_BUFFER_NAME))?;
        self.command("setlocal wfh")?;
        self.command("setlocal buftype=nofile")?;
        self.command("setlocal bufhidden=hide")?;
        self.command("setlocal noswapfile")?;
        self.command("normal! ")?;

        Ok(())
    }

    fn find_or_create_log_buf(&mut self) -> Result<Buffer, String> {
        if let Some(buf) = self.find_log_buf()? {
            return Ok(buf);
        }

        self.display_or_create_log_window()?;

        match self.find_log_buf()? {
            Some(buf) => Ok(buf),
            None => Err("failed to create buffer".to_owned()),
        }
    }

    pub fn log_writelns(&mut self, tag: &str, lines: &[String]) {
        let timestamp = Local::now().format("%T");
        let mut lines = lines.to_vec();
        lines.insert(0, format!(";; {} @ {}", tag, timestamp));
        lines.push("".to_owned());

        if let Err(msg) = self.find_or_create_log_buf().and_then(|buf| {
            self.nvim
                .lock()
                .map_err(|msg| format!("could not get nvim lock: {}", msg))
                .and_then(|mut nvim| {
                    buf.set_lines(&mut nvim, 0, 0, false, lines)
                        .map_err(|msg| format!("could not set lines: {}", msg))
                })
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
}

impl fmt::Display for Event {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

fn parse_arg<T: FromStr>(args: &[Value], index: usize, name: &str) -> Result<T, String>
where
    T::Err: fmt::Display,
{
    args.get(index)
        .ok_or_else(|| format!("expected argument at position {}", index + 1))?
        .as_str()
        .ok_or_else(|| format!("{} must be a string", name))?
        .parse()
        .map_err(|e| format!("{} parse error: {}", name, e))
}

impl Event {
    fn from(name: &str, args: &[Value]) -> Result<Event, String> {
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
            _ => return Err(format!("unknown request name: {}", name)),
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
    fn handle_request(&mut self, _name: &str, _args: Vec<Value>) -> Result<Value, Value> {
        error!("Requests are not supports, use notify");
        Err(Value::Nil)
    }
}
