#[macro_use]
extern crate log;
extern crate regex;
extern crate simplelog;

extern crate conjure;

use conjure::client::Client;
use conjure::server;
use conjure::server::Event;
use regex::Regex;
use simplelog::*;
use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io;
use std::net::SocketAddr;
use std::sync::mpsc;

fn main() {
    initialise_logger();

    info!("==============");
    info!("== Conjure! ==");
    info!("==============");

    if let Err(msg) = start() {
        error!("Error from start: {}", msg);
    }
}

struct Connection {
    eval: Client,
    addr: SocketAddr,
    expr: Regex,
}

impl Connection {
    fn connect(addr: SocketAddr, expr: Regex) -> Result<Self, String> {
        let eval = Client::connect(addr)?;
        Ok(Self { eval, addr, expr })
    }
}

fn start() -> Result<(), io::Error> {
    let mut connections: HashMap<String, Connection> = HashMap::new();

    info!("Starting Neovim RPC server");
    let (tx, rx) = mpsc::channel();
    let mut server = server::Server::start(tx)?;

    info!("Starting event channel loop");
    for event in rx.iter() {
        match event {
            Ok(event) => {
                info!("Event from server: {}", event);

                match event {
                    Event::Quit => break,
                    Event::List => {
                        let lines: Vec<String> = connections
                            .iter()
                            .map(|(key, conn)| {
                                format!("[{}] {} for files matching {}", key, conn.addr, conn.expr)
                            }).collect();

                        server.echo(&lines.join("\n"));
                    }
                    Event::Connect { key, addr, expr } => {
                        if connections.contains_key(&key) {
                            server.echoerr(&format!("[{}] Connection exists already.", key));
                        } else {
                            match Connection::connect(addr, expr.clone()) {
                                Ok(conn) => {
                                    let e_key = key.clone();
                                    connections.insert(key, conn);
                                    server.echo(&format!(
                                        "[{}] Connected to {} for files matching {}",
                                        e_key, addr, expr
                                    ))
                                }
                                Err(msg) => {
                                    server.echoerr(&format!("[{}] Connection failed: {}", key, msg))
                                }
                            }
                        }
                    }
                    Event::Disconnect { key } => {
                        if connections.contains_key(&key) {
                            if let Some(conn) = connections.remove(&key) {
                                server.echo(&format!(
                                    "[{}] Disconnected from {} for files matching {}",
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
                        // TODO Move this connection finding into it's own fn.
                        let mut _conn = connections.iter().find(|(k, c)| c.expr.is_match(&path));

                        // TODO Warn if we don't find a suitable connection.
                        // TODO Disconnect if it fails? Or leave it up to the user?
                        // TODO Read until we see an out and print it.

                        // These calls are fire and forget. There should be some other thread
                        // consuming these connections looking for their specific jobs. So one
                        // connection is actually many sockets that each have their own specific
                        // jobs.
                        server.echoerr(&format!("Would eval {} for {}", code, path));
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

fn initialise_logger() {
    if let Ok(mut path) = env::current_exe() {
        path.set_file_name("conjure.log");

        if let Ok(log_file) = File::create(path) {
            let _ = WriteLogger::init(LevelFilter::Trace, Config::default(), log_file);
        }
    }
}
