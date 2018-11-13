use neovim_lib::neovim_api::Buffer;
use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApi, Value};
use regex::Regex;
use std::fmt;
use std::io;
use std::net::SocketAddr;
use std::str::FromStr;
use std::sync::mpsc;

const LOG_BUFFER_NAME: &str = "conjure_log.cljc";

pub struct Server {
    nvim: Neovim,
}

type Sender = mpsc::Sender<Result<Event, String>>;

fn escape_quotes(s: &str) -> String {
    s.replace("\"", "\\\"")
}

impl Server {
    pub fn start(tx: Sender) -> Result<Self, io::Error> {
        let mut session = Session::new_parent()?;
        session.start_event_loop_handler(Handler::new(tx));

        Ok(Self {
            nvim: Neovim::new(session),
        })
    }

    pub fn command(&mut self, cmd: &str) -> Result<String, String> {
        self.nvim
            .command_output(cmd)
            .map_err(|msg| format!("command failed: {}", msg))
    }

    pub fn echoerr(&mut self, err: &str) {
        if let Err(msg) = self.command(&format!("echoerr \"{}\"", escape_quotes(err))) {
            error!("Failed to echoerr ({}): {}", msg, err);
        }
    }

    fn find_log_buf(&mut self, name: &str) -> Result<Option<Buffer>, String> {
        let bufs = self
            .nvim
            .list_bufs()
            .map_err(|msg| format!("failed to get buffers: {}", msg))?;

        Ok(bufs
            .iter()
            .find(|buf| &buf.get_name(&mut self.nvim).unwrap_or("".to_owned()) == name)
            .map(|buf| buf.clone()))
    }

    fn find_or_create_log_buf(&mut self, name: &str) -> Result<Buffer, String> {
        if let Some(buf) = self.find_log_buf(name)? {
            return Ok(buf);
        }

        self.command(&format!("10new {}", name))?;
        self.command(&format!("setlocal buftype=nofile"))?;
        self.command(&format!("setlocal bufhidden=hide"))?;
        self.command(&format!("setlocal noswapfile"))?;
        self.command(&format!("normal! "))?;

        match self.find_log_buf(name)? {
            Some(buf) => Ok(buf),
            None => Err("failed to create buffer".to_owned()),
        }
    }

    pub fn log_write(&mut self, lines: Vec<String>) {
        // TODO Work out why multiple windows appear.
        // TODO Add different ways to log like line, error, block, async (temp and replace).

        if let Err(msg) = self
            .find_or_create_log_buf(LOG_BUFFER_NAME)
            .and_then(|buf| {
                buf.set_lines(&mut self.nvim, 0, 0, true, lines)
                    .map_err(|msg| format!("could not set lines: {}", msg))
            }) {
            error!("Failed to log: {}", msg)
        }
    }
}

#[derive(Debug)]
pub enum Event {
    Quit,
    List,
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
