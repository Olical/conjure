use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApiAsync, Value};
use regex::Regex;
use std::fmt;
use std::io;
use std::net::SocketAddr;
use std::str::FromStr;
use std::sync::mpsc;

pub struct Server {
    nvim: Option<Neovim>,
}

type Sender = mpsc::Sender<Result<Event, String>>;

fn escape_quotes(s: &str) -> String {
    s.replace("\"", "\\\"")
}

impl Server {
    pub fn new() -> Self {
        Self { nvim: None }
    }

    pub fn start(&mut self, tx: Sender) -> Result<(), io::Error> {
        let mut session = Session::new_parent()?;
        session.start_event_loop_handler(Handler::new(tx));
        self.nvim = Some(Neovim::new(session));
        Ok(())
    }

    pub fn command(&mut self, cmd: &str) {
        if let Some(nvim) = self.nvim.as_mut() {
            nvim.command_async(cmd)
                .cb(|res| {
                    if let Err(msg) = res {
                        error!("Command failed: {}", msg);
                    }
                }).call();
        } else {
            error!("Start the server before executing commands")
        }
    }

    pub fn echo(&mut self, msg: &str) {
        self.command(&format!("echo \"{}\"", escape_quotes(msg)));
    }

    pub fn echoerr(&mut self, msg: &str) {
        self.command(&format!("echoerr \"{}\"", escape_quotes(msg)));
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
