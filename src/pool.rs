use clojure;
use editor::Server;
use regex::Regex;
use repl::{Client, Response};
use result::{error, Result};
use std::collections::{hash_map, HashMap};
use std::net::SocketAddr;
use std::thread;
use util;

// TODO What if a REPL server or socket dies? (heartbeat?)
// TODO Show some sort of placeholder while evaling.
// TODO Go to definition.
// TODO Completions.

pub struct Connection {
    user: Client,

    pub addr: SocketAddr,
    pub expr: Regex,
    pub lang: clojure::Lang,
}

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "connection doesn't exist for that key: {}", key)]
    ConnectionMissing { key: String },
}

impl Connection {
    pub fn connect(addr: SocketAddr, expr: Regex, lang: clojure::Lang) -> Result<Self> {
        Ok(Self {
            user: Client::connect(addr)?,

            addr,
            expr,
            lang,
        })
    }

    pub fn start_response_loops(&self, key: &str, server: &Server) -> Result<()> {
        let mut user = self.user.try_clone()?;
        let mut user_server = server.clone();
        let user_key = key.to_string();

        user.write(&clojure::eval(
            &clojure::bootstrap(),
            "conjure.repl",
            &self.lang,
        ))?;

        thread::spawn(move || {
            let log = |server: &mut Server, tag_suffix, line_prefix, msg: String| {
                let lines: Vec<String> = msg
                    .split('\n')
                    .map(|line| format!("{}{}", line_prefix, line))
                    .collect();

                server.log_writelns(&format!("{} {}", user_key, tag_suffix), &lines);
            };

            for response in user.responses().expect("couldn't get responses") {
                match response {
                    Ok(Response::Ret(msg)) => log(&mut user_server, "ret", "", msg),
                    Ok(Response::Tap(msg)) => log(&mut user_server, "tap", "", msg),
                    Ok(Response::Out(msg)) => log(&mut user_server, "out", ";; ", msg),
                    Ok(Response::Err(msg)) => log(&mut user_server, "err", ";; ", msg),

                    Err(msg) => {
                        user_server.err_writeln(&format!("Error from user connection: {}", msg))
                    }
                }
            }
        });

        Ok(())
    }
}

#[derive(Default)]
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
        expr: &Regex,
        lang: clojure::Lang,
    ) -> Result<()> {
        Connection::connect(addr, expr.clone(), lang)
            .and_then(|conn| {
                conn.start_response_loops(&format!("[{}]", key), server)?;
                Ok(conn)
            }).map(|conn| {
                self.conns.insert(key.to_owned(), conn);
            })
    }

    pub fn disconnect(&mut self, key: &str) -> Result<()> {
        if self.conns.contains_key(key) {
            self.conns.remove(key);
            Ok(())
        } else {
            Err(error(Error::ConnectionMissing {
                key: key.to_owned(),
            }))
        }
    }

    pub fn eval(&mut self, code: &str, path: &str) -> Result<()> {
        let matches = self
            .conns
            .iter_mut()
            .filter(|(_, conn)| conn.expr.is_match(&path));

        let src = util::clojure_src(path).unwrap_or_else(|_| "".to_owned());
        let ns = util::clojure_ns(&src).unwrap_or_else(|| "user".to_owned());

        for (_, conn) in matches {
            conn.user.write(&clojure::eval(code, &ns, &conn.lang))?
        }

        Ok(())
    }

    pub fn doc(&mut self, name: &str, path: &str) -> Result<()> {
        self.eval(&clojure::doc(name), path)
    }
}
