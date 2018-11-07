use neovim_lib::{session, Neovim, NeovimApi, Value};
use regex;
use std::fmt;
use std::io;
use std::net;
use std::str::FromStr;
use std::sync::mpsc;

pub struct Server {
    nvim: Neovim,
}

type Sender = mpsc::Sender<Result<Event, String>>;

impl Server {
    pub fn start(tx: Sender) -> Result<Self, io::Error> {
        let mut session = session::Session::new_parent()?;
        session.start_event_loop_handler(Handler::new(tx));
        let nvim = Neovim::new(session);
        Ok(Self { nvim })
    }

    pub fn echo(&mut self, msg: &str) {
        if let Err(msg) = self.nvim.out_write(&format!("{}\n", msg)) {
            error!("Failed to echo {}", msg);
        }
    }

    pub fn echoerr(&mut self, msg: &str) {
        if let Err(msg) = self.nvim.err_write(&format!("{}\n", msg)) {
            error!("Failed to echoerr {}", msg);
        }
    }
}

#[derive(Debug)]
pub enum Event {
    Quit,
    List,
    Connect {
        addr: net::SocketAddr,
        expr: regex::Regex,
    },
    Disconnect {
        index: usize,
    },
    Eval {
        path: String,
        code: String,
    },
}

impl fmt::Display for Event {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

fn parse_index<T: FromStr>(args: &[Value], index: usize, name: &str) -> Result<T, String>
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
                let addr = parse_index(&args, 0, "addr")?;
                let expr = parse_index(&args, 1, "expr")?;

                Event::Connect { addr, expr }
            }
            "disconnect" => {
                let index = parse_index(&args, 0, "index")?;
                Event::Disconnect { index }
            }
            "eval" => {
                let path = parse_index(&args, 0, "path")?;
                let code = parse_index(&args, 0, "code")?;
                Event::Eval { path, code }
            }
            _ => return Err(format!("unknown request name `{}`", name)),
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

    fn handle_request(&mut self, _name: &str, _args: Vec<Value>) -> Result<Value, Value> {
        error!("Request not supported, use notify");
        Err(Value::from(false))
    }
}
