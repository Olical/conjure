use neovim;
use neovim::session;
use regex;
use std::net;

type HandlerFn = fn(Request) -> Result<neovim::Value, neovim::Value>;

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
    Error(String),
}

fn parse_index<T: std::str::FromStr>(args: &Vec<neovim::Value>, index: usize) -> Option<T> {
    args.get(index)?.as_str()?.parse().ok()
}

impl Request {
    fn from(name: &str, args: Vec<neovim::Value>) -> Request {
        match name {
            "exit" => Request::Exit,
            "connect" => {
                if let (Some(addr), Some(expr)) = (parse_index(&args, 0), parse_index(&args, 1)) {
                    Request::Connect { addr, expr }
                } else {
                    Request::Error("connect expects an address and expression".to_owned())
                }
            }
            _ => Request::Error(format!("unknown request name `{}`", name)),
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

impl neovim::Handler for Handler {
    fn handle_notify(&mut self, _name: &str, _args: Vec<neovim::Value>) {
        eprintln!("notify not supported, use request");
    }

    fn handle_request(
        &mut self,
        name: &str,
        args: Vec<neovim::Value>,
    ) -> Result<neovim::Value, neovim::Value> {
        (self.handler)(Request::from(name, args))
    }
}
