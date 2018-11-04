use neovim_lib::{session, Value};
use regex;
use std::fmt::Display;
use std::net;
use std::str::FromStr;
use std::sync::mpsc;

pub struct Server {
    session: session::Session,
}

impl Server {
    pub fn new() -> Server {
        let session = session::Session::new_parent().expect("can't create neovim session");
        Server { session }
    }

    pub fn start(&mut self, tx: mpsc::Sender<Event>) {
        self.session.start_event_loop_handler(Handler::new(tx));
    }
}

pub enum Event {
    Quit,
    Connect {
        addr: net::SocketAddr,
        expr: regex::Regex,
    },
}

fn parse_index<T: FromStr>(args: &[Value], index: usize) -> Result<T, String>
where
    T::Err: Display,
{
    args.get(index)
        .ok_or_else(|| format!("expected argument at position {}", index + 1))?
        .as_str()
        .ok_or_else(|| String::from("expr must be a string"))?
        .parse()
        .map_err(|e| format!("expr parse error: {}", e))
}

impl Event {
    fn from(name: &str, args: Vec<Value>) -> Result<Event, String> {
        let event = match name {
            "exit" => Event::Quit,
            "connect" => {
                let addr = parse_index(&args, 0).map_err(|e| format!("invalid addr: {}", e))?;
                let expr = parse_index(&args, 1).map_err(|e| format!("invalid expr: {}", e))?;

                Event::Connect { addr, expr }
            }
            _ => return Err(format!("unknown request name `{}`", name)),
        };

        Ok(event)
    }
}

struct Handler {
    tx: mpsc::Sender<Event>,
}

impl Handler {
    fn new(tx: mpsc::Sender<Event>) -> Handler {
        Handler { tx }
    }
}

impl neovim_lib::Handler for Handler {
    fn handle_notify(&mut self, name: &str, args: Vec<Value>) {
        match Event::from(name, args) {
            Ok(event) => self
                .tx
                .send(event)
                .expect("could not send event through channel"),
            Err(msg) => eprintln!("invalid event: {}", msg),
        }
    }

    fn handle_request(&mut self, _name: &str, _args: Vec<Value>) -> Result<Value, Value> {
        eprintln!("request not supported, use notify");
        Err(Value::from(false))
    }
}
