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
use std::thread;

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
    default: Client,
    addr: SocketAddr,
    expr: Regex,
}

impl Connection {
    fn connect(addr: SocketAddr, expr: Regex) -> Result<Self, String> {
        let default = Client::connect(addr)?;
        let default_reader = default.try_clone()?;

        thread::spawn(|| {
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

fn connnection_for_path<'a>(
    connections: &'a mut HashMap<String, Connection>,
    path: &str,
) -> Option<(&'a String, &'a mut Connection)> {
    connections
        .iter_mut()
        .find(|(_key, connection)| connection.expr.is_match(&path))
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
                        if connections.is_empty() {
                            server.echo("No connections");
                        } else {
                            let lines: Vec<String> = connections
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
                        if connections.contains_key(&key) {
                            server.echoerr(&format!("[{}] Connection exists already", key));
                        } else {
                            match Connection::connect(addr, expr.clone()) {
                                Ok(conn) => {
                                    let e_key = key.clone();
                                    connections.insert(key, conn);
                                    server.echo(&format!(
                                        "[{}] Connected to {} for files matching '{}'",
                                        e_key, addr, expr
                                    ));
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
                        if let Some((key, connection)) =
                            connnection_for_path(&mut connections, &path)
                        {
                            let mut code_sample = code.replace("\n", "");
                            let pre_truncate = code_sample.len();
                            code_sample.truncate(20);

                            if pre_truncate < code_sample.len() {
                                code_sample.push_str("…");
                            }

                            server.echo(&format!("[{}] Evaluating: {}", key, code_sample));

                            if let Err(msg) = connection.default.write(&code) {
                                server
                                    .echoerr(&format!("Error writing to default client: {}", msg));
                            }
                        } else {
                            server.echoerr(&format!("No connection found for path: {}", path));
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

fn initialise_logger() {
    if let Ok(mut path) = env::current_exe() {
        path.set_file_name("conjure.log");

        if let Ok(log_file) = File::create(path) {
            let _ = WriteLogger::init(LevelFilter::Trace, Config::default(), log_file);
        }
    }
}
