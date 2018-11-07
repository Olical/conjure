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
use std::env;
use std::fs::File;
use std::io;
use std::net::SocketAddr;
use std::sync::mpsc;

fn main() {
    initialise_logger();

    info!("===================");
    info!("= Conjure things! =");
    info!("===================");

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
    let mut connections: Vec<Connection> = Vec::new();

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
                        for (index, conn) in connections.iter().enumerate() {
                            server.echo(&format!(
                                "[{}] {} for files matching {}",
                                index, conn.addr, conn.expr
                            ))
                        }
                    }
                    Event::Connect { addr, expr } => {
                        // TODO Don't connect if duplicate, or leave it up to the user?
                        match Connection::connect(addr, expr.clone()) {
                            Ok(conn) => {
                                connections.push(conn);
                                server.echo(&format!(
                                    "Connected to {} for files matching {}",
                                    addr, expr
                                ))
                            }
                            Err(msg) => server.echoerr(&format!("Connection failed: {}", msg)),
                        }
                    }
                    Event::Disconnect { index } => {
                        if connections.get(index).is_some() {
                            let conn = connections.remove(index);
                            server.echo(&format!(
                                "Disconnected from {} for files matching {}",
                                conn.addr, conn.expr
                            ));
                        } else {
                            server.echoerr(&format!(
                                "Connection {} doesn't exist, try listing them",
                                index
                            ));
                        }
                    }
                    Event::Eval { code, path } => {
                        // TODO Move this connection finding into it's own fn.
                        let mut _conn = connections.iter().find(|c| c.expr.is_match(&path));

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
                error!("Error from server: {}", msg);
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
