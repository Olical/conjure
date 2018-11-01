use neovim;
use neovim::session;

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
    Connect { addr: String, expr: String },
    Error(String),
}

impl Request {
    fn from(name: &str, args: Vec<neovim::Value>) -> Request {
        match name {
            "exit" => Request::Exit,
            "connect" => Request::Connect {
                addr: args[0].as_str().unwrap().to_owned(),
                expr: args[1].as_str().unwrap().to_owned(),
            },
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
