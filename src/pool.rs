use editor::Server;
use regex::Regex;
use repl::{Client, Response};
use result::{error, Result};
use std::collections::{hash_map, HashMap};
use std::env::current_exe;
use std::net::SocketAddr;
use std::thread;

pub struct Connection {
    eval: Client,

    pub addr: SocketAddr,
    pub expr: Regex,
}

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "connection already exists for that key: {}", key)]
    ConnectionExists { key: String },

    #[fail(display = "connection doesn't exist for that key: {}", key)]
    ConnectionMissing { key: String },

    #[fail(display = "couldn't build the conjure.cljc path")]
    NoConjureCljcPath,
}

fn clojure_path(file: &str) -> Result<String> {
    let prefix = "../../clojure/";
    let mut exe = current_exe()?;
    exe.pop();

    match exe.join(prefix).join(file).to_str() {
        Some(result) => Ok(result.to_owned()),
        None => Err(error(Error::NoConjureCljcPath)),
    }
}

impl Connection {
    pub fn connect(addr: SocketAddr, expr: Regex) -> Result<Self> {
        Ok(Self {
            eval: Client::connect(addr)?,

            addr,
            expr,
        })
    }

    pub fn start_response_loops(&self, key: String, server: &Server) -> Result<()> {
        let mut eval = self.eval.try_clone()?;
        let mut eval_server = server.clone();
        let eval_key = key.clone();

        let core_path = clojure_path("conjure/core.cljc")?;
        eval.write(&format!("(load-file \"{}\")", core_path))?;

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
                    Ok(Response::Tap(msg)) => log(&mut eval_server, "tap", "", msg),
                    Ok(Response::Out(msg)) => log(&mut eval_server, "out", ";; ", msg),
                    Ok(Response::Err(msg)) => log(&mut eval_server, "err", ";; ", msg),

                    Err(msg) => eval_server.err_writeln(&format!("Error from eval: {}", msg)),
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
    ) -> Result<()> {
        if self.conns.contains_key(key) {
            return Err(error(Error::ConnectionExists {
                key: key.to_owned(),
            }));
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

    pub fn disconnect(&mut self, key: &str) -> Result<()> {
        if self.conns.contains_key(key) {
            self.conns.remove(key);
            Ok(())
        } else {
            return Err(error(Error::ConnectionMissing {
                key: key.to_owned(),
            }));
        }
    }

    pub fn eval(&mut self, code: &str, path: &str) -> Result<()> {
        let matches = self
            .conns
            .iter_mut()
            .filter(|(_, conn)| conn.expr.is_match(&path));

        for (_, conn) in matches {
            conn.eval.write(&code)?;
        }

        Ok(())
    }
}
