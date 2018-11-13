use client::Client;
use regex::Regex;
use server::{Event, Server};
use std::collections::HashMap;
use std::io;
use std::net::SocketAddr;
use std::sync::mpsc;

// TODO Implement a heartbeat for connections.

struct Connection {
    eval: Client,

    addr: SocketAddr,
    expr: Regex,
}

impl Connection {
    fn connect(addr: SocketAddr, expr: Regex) -> Result<Self, String> {
        Ok(Self {
            eval: Client::connect(addr)?,

            addr,
            expr,
        })
    }
}

pub struct System {
    conns: HashMap<String, Connection>,
    server: Server,
}

impl System {
    pub fn start() -> Result<Self, io::Error> {
        let (tx, rx) = mpsc::channel();
        let server = Server::start(tx)?;
        let mut system = Self {
            conns: HashMap::new(),
            server: server,
        };

        for event in rx.iter() {
            match event {
                Ok(event) => {
                    info!("Event from server: {}", event);

                    match event {
                        Event::Quit => break,
                        Event::List => system.handle_list(),
                        Event::Connect { key, addr, expr } => {
                            system.handle_connect(key, addr, expr)
                        }
                        Event::Disconnect { key } => system.handle_disconnect(key),
                        Event::Eval { code, path } => system.handle_eval(code, path),
                    }
                }
                Err(msg) => {
                    error!("Error from Neovim: {}", msg);
                    system
                        .server
                        .echoerr(&format!("Error parsing command: {}", msg))
                }
            }
        }

        Ok(system)
    }

    fn handle_list(&mut self) {
        if self.conns.is_empty() {
            self.server.log_write(vec![";; No connections".to_owned()]);
        } else {
            let lines: Vec<String> = self
                .conns
                .iter()
                .map(|(key, conn)| {
                    format!(
                        ";; [{}] {} for files matching '{}'",
                        key, conn.addr, conn.expr
                    )
                }).collect();

            self.server.log_write(lines);
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
            if let Err(msg) = conn.eval.write(&code) {
                self.server
                    .echoerr(&format!("Error writing to eval client: {}", msg));
            }
        }
    }
}
