use client::Client;
use regex::Regex;
use server::{Event, Server};
use std::collections::HashMap;
use std::io;
use std::net::SocketAddr;
use std::sync::mpsc;
use std::thread;

pub struct System {
    conns: HashMap<String, Connection>,
    server: Server,
}

impl System {
    pub fn new() -> Self {
        Self {
            conns: HashMap::new(),
            server: Server::new(),
        }
    }

    pub fn start(&mut self) -> Result<(), io::Error> {
        info!("Starting Neovim RPC server");
        let (tx, rx) = mpsc::channel();
        self.server.start(tx)?;

        info!("Starting event channel loop");
        for event in rx.iter() {
            match event {
                Ok(event) => {
                    info!("Event from server: {}", event);

                    match event {
                        Event::Quit => break,
                        Event::List => self.handle_list(),
                        Event::Connect { key, addr, expr } => self.handle_connect(key, addr, expr),
                        Event::Disconnect { key } => self.handle_disconnect(key),
                        Event::Eval { code, path } => self.handle_eval(code, path),
                    }
                }
                Err(msg) => {
                    error!("Error from Neovim: {}", msg);
                    self.server
                        .echoerr(&format!("Error parsing command: {}", msg))
                }
            }
        }

        Ok(())
    }

    fn handle_list(&mut self) {
        if self.conns.is_empty() {
            self.server.echo("No connections");
        } else {
            let lines: Vec<String> = self
                .conns
                .iter()
                .map(|(key, conn)| {
                    format!("[{}] {} for files matching '{}'", key, conn.addr, conn.expr)
                }).collect();

            self.server.echo(&lines.join("\n"));
        }
    }

    fn handle_connect(&mut self, key: String, addr: SocketAddr, expr: Regex) {
        if self.conns.contains_key(&key) {
            self.server
                .echoerr(&format!("[{}] Connection exists already", key));
        } else {
            match Connection::connect(addr, expr.clone()) {
                Ok(conn) => {
                    let e_key = key.clone();
                    self.conns.insert(key, conn);
                    self.server.echo(&format!(
                        "[{}] Connected to {} for files matching '{}'",
                        e_key, addr, expr
                    ));
                }
                Err(msg) => self
                    .server
                    .echoerr(&format!("[{}] Connection failed: {}", key, msg)),
            }
        }
    }

    fn handle_disconnect(&mut self, key: String) {
        if self.conns.contains_key(&key) {
            if let Some(conn) = self.conns.remove(&key) {
                self.server.echo(&format!(
                    "[{}] Disconnected from {} for files matching '{}'",
                    key, conn.addr, conn.expr
                ));
            }
        } else {
            self.server.echoerr(&format!(
                "Connection {} doesn't exist, try listing them",
                key
            ));
        }
    }

    fn handle_eval(&mut self, code: String, path: String) {
        let matches = self
            .conns
            .iter_mut()
            .filter(|(_, conn)| conn.expr.is_match(&path));

        for (_, conn) in matches {
            if let Err(msg) = conn.default.write(&code) {
                self.server
                    .echoerr(&format!("Error writing to default client: {}", msg));
            }
        }
    }
}

struct Connection {
    default: Client,
    addr: SocketAddr,
    expr: Regex,
}

impl Connection {
    fn connect(addr: SocketAddr, expr: Regex) -> Result<Self, String> {
        let default = Client::connect(addr)?;
        let default_reader = default.try_clone()?;

        thread::spawn(|| {
            // TODO These should log to the Conjure buffer.
            for response in default_reader.responses() {
                info!("RESPONSE: {:?}", response);
            }
        });

        Ok(Self {
            default,
            addr,
            expr,
        })
    }
}
