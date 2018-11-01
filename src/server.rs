use neovim;
use neovim::session;
use std::net::{SocketAddr, ToSocketAddrs};

// TODO Connect should be std::net sockets and regexes.
// TODO Replace unwrap with some eprintln.

type HandlerFn = fn(Request) -> Result<neovim::Value, neovim::Value>;

pub fn start(handler: HandlerFn) -> session::Session {
    let mut session = session::Session::new_parent().expect("can't create neovim session");
    session.start_event_loop_handler(Handler::new(handler));
    session
}

pub enum Request {
    Exit,
    Connect { addr: SocketAddr, expr: String },
    Error(String),
}

fn extract_and_parse<T: std::str::FromStr>(args: &Vec<neovim::Value>, index: usize) -> Option<T> {
    args.get(index)?.as_str()?.parse().ok()
}

impl Request {
    fn from(name: &str, args: Vec<neovim::Value>) -> Request {
        match name {
            "exit" => Request::Exit,
            "connect" => {
                if let Some(addr) = extract_and_parse(&args, 0) {
                    let expr = String::new();
                    Request::Connect { addr, expr }
                } else {
                    Request::Error("addr should be a valid socket address".to_owned())
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
