use editor::Server;
use regex::Regex;
use repl::{Client, Response};
use std::collections::{hash_map, HashMap};
use std::net::SocketAddr;
use std::thread;

pub struct Connection {
    eval: Client,
    doc: Client,

    pub addr: SocketAddr,
    pub expr: Regex,
}

impl Connection {
    pub fn connect(addr: SocketAddr, expr: Regex) -> Result<Self, String> {
        Ok(Self {
            eval: Client::connect(addr)?,
            doc: Client::connect(addr)?,

            addr,
            expr,
        })
    }

    pub fn start_response_loops(&self, key: String, server: &Server) -> Result<(), String> {
        let eval = self.eval.try_clone()?;
        let mut eval_server = server.clone();
        let eval_key = key.clone();

        thread::spawn(move || {
            let log = |server: &mut Server, tag_suffix, line_prefix, msg: String| {
                let lines: Vec<String> = msg
                    .split("\n")
                    .map(|line| format!("{}{}", line_prefix, line))
                    .collect();

                server.log_writelns(&format!("{} {}", eval_key, tag_suffix), &lines);
            };

            for response in eval.responses() {
                match response {
                    Ok(Response::Ret(msg)) => log(&mut eval_server, "ret", "", msg),
                    Ok(Response::Tap(msg)) => log(&mut eval_server, "tap", ";; ", msg),
                    Ok(Response::Out(msg)) => log(&mut eval_server, "out", ";; ", msg),
                    Ok(Response::Err(msg)) => log(&mut eval_server, "err", ";; ", msg),

                    Err(msg) => eval_server.err_writeln(&format!("Error from eval: {}", msg)),
                }
            }
        });

        let doc = self.doc.try_clone()?;
        let mut doc_server = server.clone();
        let doc_key = key.clone();

        thread::spawn(move || {
            let mut out_acc: String = String::new();

            // TODO DRY this.
            let log = |server: &mut Server, tag_suffix, line_prefix, msg: &str| {
                let lines: Vec<String> = msg
                    .split("\n")
                    .map(|line| format!("{}{}", line_prefix, line))
                    .collect();

                server.log_writelns(&format!("{} {}", doc_key, tag_suffix), &lines);
            };

            for response in doc.responses() {
                match response {
                    Ok(Response::Out(msg)) => {
                        if msg != "-------------------------\n" {
                            out_acc.push_str(&msg);
                        }
                    }
                    Ok(Response::Ret(msg)) => {
                        if msg != "nil" {
                            out_acc.push_str(&msg);
                        } else {
                            out_acc.pop();
                        }

                        log(&mut doc_server, "doc", ";; ", &out_acc);

                        out_acc.truncate(0);
                    }
                    Ok(Response::Err(msg)) => {
                        log(&mut doc_server, "doc err", ";; ", &msg);
                        out_acc.truncate(0);
                    }
                    Ok(Response::Tap(_)) => (),

                    Err(msg) => doc_server.err_writeln(&format!("Error from doc: {}", msg)),
                }
            }
        });

        Ok(())
    }
}

pub struct Pool {
    conns: HashMap<String, Connection>,
}

impl Pool {
    pub fn new() -> Self {
        Self {
            conns: HashMap::new(),
        }
    }

    pub fn has_connections(&self) -> bool {
        !self.conns.is_empty()
    }

    pub fn iter(&self) -> hash_map::Iter<String, Connection> {
        self.conns.iter()
    }

    pub fn connect(
        &mut self,
        key: &str,
        server: &Server,
        addr: SocketAddr,
        expr: Regex,
    ) -> Result<(), String> {
        if self.conns.contains_key(key) {
            return Err("connection already exists".to_owned());
        } else {
            Connection::connect(addr, expr.clone())
                .and_then(|conn| {
                    conn.start_response_loops(format!("[{}]", key), server)?;
                    Ok(conn)
                }).map(|conn| {
                    self.conns.insert(key.to_owned(), conn);
                })
        }
    }

    pub fn disconnect(&mut self, key: &str) -> Result<(), String> {
        if self.conns.contains_key(key) {
            self.conns.remove(key);
            Ok(())
        } else {
            return Err(format!("{} doesn't exist", key));
        }
    }

    pub fn eval(&mut self, code: &str, path: &str) -> Result<(), String> {
        let matches = self
            .conns
            .iter_mut()
            .filter(|(_, conn)| conn.expr.is_match(&path));

        for (_, conn) in matches {
            conn.eval.write(&code)?;
        }

        Ok(())
    }

    pub fn doc(&mut self, symbol: &str, path: &str) -> Result<(), String> {
        // TODO DRY this.
        let matches = self
            .conns
            .iter_mut()
            .filter(|(_, conn)| conn.expr.is_match(&path));

        for (_, conn) in matches {
            conn.doc.write(&format!("(doc {})", symbol))?;
        }

        Ok(())
    }
}
