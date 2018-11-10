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
}

impl System {
    pub fn new() -> Self {
        Self {
            conns: HashMap::new(),
        }
    }

    pub fn start(&mut self) -> Result<(), io::Error> {
        info!("Starting Neovim RPC server");
        let (tx, rx) = mpsc::channel();
        let mut server = Server::start(tx)?;

        info!("Starting event channel loop");
        for event in rx.iter() {
            match event {
                Ok(event) => {
                    info!("Event from server: {}", event);

                    match event {
                        Event::Quit => break,
                        Event::List => {
                            if self.conns.is_empty() {
                                server.echo("No connections");
                            } else {
                                let lines: Vec<String> = self
                                    .conns
                                    .iter()
                                    .map(|(key, conn)| {
                                        format!(
                                            "[{}] {} for files matching '{}'",
                                            key, conn.addr, conn.expr
                                        )
                                    }).collect();

                                server.echo(&lines.join("\n"));
                            }
                        }
                        Event::Connect { key, addr, expr } => {
                            if self.conns.contains_key(&key) {
                                server.echoerr(&format!("[{}] Connection exists already", key));
                            } else {
                                match Connection::connect(addr, expr.clone()) {
                                    Ok(conn) => {
                                        let e_key = key.clone();
                                        self.conns.insert(key, conn);
                                        server.echo(&format!(
                                            "[{}] Connected to {} for files matching '{}'",
                                            e_key, addr, expr
                                        ));
                                    }
                                    Err(msg) => server
                                        .echoerr(&format!("[{}] Connection failed: {}", key, msg)),
                                }
                            }
                        }
                        Event::Disconnect { key } => {
                            if self.conns.contains_key(&key) {
                                if let Some(conn) = self.conns.remove(&key) {
                                    server.echo(&format!(
                                        "[{}] Disconnected from {} for files matching '{}'",
                                        key, conn.addr, conn.expr
                                    ));
                                }
                            } else {
                                server.echoerr(&format!(
                                    "Connection {} doesn't exist, try listing them",
                                    key
                                ));
                            }
                        }
                        Event::Eval { code, path } => {
                            let matches = self
                                .conns
                                .iter_mut()
                                .filter(|(_, conn)| conn.expr.is_match(&path));

                            for (_, conn) in matches {
                                if let Err(msg) = conn.default.write(&code) {
                                    server.echoerr(&format!(
                                        "Error writing to default client: {}",
                                        msg
                                    ));
                                }
                            }
                        }
                    }
                }
                Err(msg) => {
                    error!("Error from Neovim: {}", msg);
                    server.echoerr(&format!("Error parsing command: {}", msg))
                }
            }
        }

        Ok(())
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
