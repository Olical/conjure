use neovim_lib::{session, Value};
use regex;
use std::net;

type HandlerFn = fn(Request) -> Result<Value, Value>;

pub fn start(handler: HandlerFn) -> session::Session {
    let mut session = session::Session::new_parent().expect("can't create neovim session");
    session.start_event_loop_handler(Handler::new(handler));
    session
}

pub enum Request {
    Exit,
    Connect {
        addr: net::SocketAddr,
        expr: regex::Regex,
    },
}

fn parse_index<T: std::str::FromStr>(args: &Vec<Value>, index: usize) -> Option<T> {
    args.get(index)?.as_str()?.parse().ok()
}

impl Request {
    fn from(name: &str, args: Vec<Value>) -> Result<Request, String> {
        match name {
            "exit" => Ok(Request::Exit),
            "connect" => match (parse_index(&args, 0), parse_index(&args, 1)) {
                (Some(addr), Some(expr)) => Ok(Request::Connect { addr, expr }),
                (None, None) => Err("failed to parse addr or expr".to_owned()),
                (Some(_), None) => Err("failed to parse expr".to_owned()),
                (None, Some(_)) => Err("failed to parse addr".to_owned()),
            },
            _ => Err(format!("unknown request name `{}`", name)),
        }
    }
}

struct Handler {
    handler: HandlerFn,
}

impl Handler {
    fn new(handler: HandlerFn) -> Handler {
        Handler { handler }
    }
}

impl neovim_lib::Handler for Handler {
    fn handle_notify(&mut self, _name: &str, _args: Vec<Value>) {
        eprintln!("notify not supported, use request");
    }

    fn handle_request(&mut self, name: &str, args: Vec<Value>) -> Result<Value, Value> {
        match Request::from(name, args) {
            Ok(request) => (self.handler)(request),
            Err(msg) => Err(Value::String(
                format!("Error while parsing request: {}", msg).into(),
            )),
        }
    }
}
