use neovim_lib::neovim_api::Buffer;
use neovim_lib::session::Session;
use neovim_lib::{Neovim, NeovimApi, NeovimApiAsync, Value};
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

    fn get_nvim(&self) -> &Neovim {
        &self.nvim.expect("server not started")
    }

    pub fn command_async(&mut self, cmd: &str) {
        let nvim = self.get_nvim();

        nvim.command_async(cmd)
            .cb(|res| {
                if let Err(msg) = res {
                    error!("Command failed: {}", msg);
                }
            }).call();
    }

    pub fn command(&mut self, cmd: &str) -> Result<(), String> {
        self.get_nvim()
            .command(cmd)
            .map_err(|msg| format!("command failed: {}", msg))
    }

    pub fn echo(&mut self, msg: &str) {
        self.command_async(&format!("echo \"{}\"", escape_quotes(msg)));
    }

    pub fn echoerr(&mut self, msg: &str) {
        self.command_async(&format!("echoerr \"{}\"", escape_quotes(msg)));
    }

    fn find_buf(&mut self, name: &str) -> Result<Option<&Buffer>, String> {
        let bufs = self
            .nvim
            .as_mut()
            .unwrap()
            .list_bufs()
            .map_err(|msg| format!("failed to get buffers: {}", msg))?;

        Ok(bufs.iter().find(|buf| {
            &buf.get_name(self.nvim.as_mut().unwrap())
                .unwrap_or("".to_owned())
                == name
        }))
    }

    fn find_or_create_buf(&mut self, name: &str) -> Result<&Buffer, String> {
        if let Some(buf) = self.find_buf(name)? {
            return Ok(buf);
        }

        self.command("badd /tmp/conjure.cljc")?;

        match self.find_buf(name)? {
            Some(buf) => Ok(buf),
            None => Err("failed to create buffer".to_owned()),
        }
    }

    pub fn display(&mut self, msg: &str) {
        let nvim = self.get_nvim();

        // TODO Implement upsert buffer for this log thing. Maybe move more output to it like the
        // connection listing. Keep all Neovim stuff in here but slight config like the name of it
        // in system. Or if I'm only going to have one, hard code it all in here so I can just say
        // "print this!" whenever I want and forget about it.
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
