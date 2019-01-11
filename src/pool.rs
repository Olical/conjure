use clojure;
use editor::Server;
use regex::Regex;
use repl::{Client, Response};
use result::{error, Result};
use std::collections::{hash_map, HashMap};
use std::net::SocketAddr;
use std::thread;
use util;

#[derive(Debug)]
pub struct Connection {
    eval: Client,
    go_to_definition: Client,
    completions: Client,

    pub user_ns: String,
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
            eval: Client::connect(addr)?,
            go_to_definition: Client::connect(addr)?,
            completions: Client::connect(addr)?,

            user_ns: match lang {
                clojure::Lang::Clojure => "user".to_owned(),
                clojure::Lang::ClojureScript => "cljs.user".to_owned(),
            },
            addr,
            expr,
            lang,
        })
    }

    pub fn start_response_loops(&self, key: &str, server: &Server) -> Result<()> {
        let mut eval = self.eval.try_clone()?;
        let mut eval_server = server.clone();
        let eval_key = key.to_string();

        eval.write(&clojure::eval(
            &clojure::bootstrap(),
            &self.user_ns,
            &self.lang,
        ))?;

        thread::spawn(move || {
            let log = |server: &mut Server, tag_suffix, line_prefix, msg: String| {
                let lines: Vec<String> = msg
                    .split('\n')
                    .map(|line| format!("{}{}", line_prefix, line))
                    .collect();

                server.log_writelns(&format!("{} {}", eval_key, tag_suffix), &lines);
            };

            for response in eval.responses().expect("couldn't get responses") {
                match response {
                    Ok(Response::Ret(msg)) => log(&mut eval_server, "ret", "", msg),
                    Ok(Response::Tap(msg)) => log(&mut eval_server, "tap", "", msg),
                    Ok(Response::Out(msg)) => log(&mut eval_server, "out", ";; ", msg),
                    Ok(Response::Err(msg)) => log(&mut eval_server, "err", ";; ", msg),

                    Err(msg) => {
                        eval_server.err_writeln(&format!("Error from eval connection: {}", msg))
                    }
                }
            }
        });

        let go_to_definition = self.go_to_definition.try_clone()?;
        let mut go_to_definition_server = server.clone();

        thread::spawn(move || {
            for response in go_to_definition
                .responses()
                .expect("couldn't get responses")
            {
                match response {
                    Ok(Response::Ret(msg)) => if let Some(loc) = util::parse_location(&msg) {
                        if let Err(msg) = go_to_definition_server.go_to(loc) {
                            go_to_definition_server
                                .err_writeln(&format!("Error while going to definition: {}", msg))
                        }
                    } else if msg == ":unknown" {
                        go_to_definition_server.err_writeln("Location unknown");
                    },
                    Ok(Response::Err(msg)) => error!("Error message from go to location: {}", msg),
                    Ok(Response::Tap(_)) => (),
                    Ok(Response::Out(_)) => (),

                    Err(msg) => go_to_definition_server
                        .err_writeln(&format!("Error from definition connection: {}", msg)),
                }
            }
        });

        let completions = self.completions.try_clone()?;
        let mut completions_server = server.clone();

        thread::spawn(move || {
            for response in completions.responses().expect("couldn't get responses") {
                match response {
                    Ok(Response::Ret(msg)) => {
                        if let Some(completions) = util::parse_completions(&msg) {
                            if let Err(msg) = completions_server.update_completions(&completions) {
                                completions_server
                                    .err_writeln(&format!("Error while completing: {}", msg))
                            }
                        }
                    }
                    Ok(Response::Err(msg)) => error!("Error message from completions: {}", msg),
                    Ok(Response::Tap(_)) => (),
                    Ok(Response::Out(_)) => (),

                    Err(msg) => completions_server
                        .err_writeln(&format!("Error from completion connection: {}", msg)),
                }
            }
        });

        Ok(())
    }
}

impl Drop for Connection {
    fn drop(&mut self) {
        if let Err(msg) = self.eval.quit() {
            error!("Failed to quit REPL cleanly: {}", msg);
        }
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

        let src = util::slurp(path).unwrap_or_else(|_| "".to_owned());
        let ns_opt = util::ns(&src);

        for (_, conn) in matches {
            info!("Evaluating through: {:?}", conn);
            let ns = ns_opt.clone().unwrap_or_else(|| conn.user_ns.clone());
            conn.eval.write(&clojure::eval(code, &ns, &conn.lang))?
        }

        Ok(())
    }

    pub fn go_to_definition(&mut self, name: &str, path: &str) -> Result<()> {
        if let Some((_, conn)) = self
            .conns
            .iter_mut()
            .find(|(_, conn)| conn.expr.is_match(&path))
        {
            let src = util::slurp(path).unwrap_or_else(|_| "".to_owned());
            let ns = util::ns(&src).unwrap_or_else(|| conn.user_ns.clone());

            info!("Looking up definition through: {:?}", conn);
            conn.go_to_definition.write(&clojure::eval(
                &clojure::definition(&name),
                &ns,
                &conn.lang,
            ))?;
        }

        Ok(())
    }

    pub fn update_completions(&mut self, path: &str) -> Result<()> {
        if let Some((_, conn)) = self
            .conns
            .iter_mut()
            .find(|(_, conn)| conn.expr.is_match(&path))
        {
            let src = util::slurp(path).unwrap_or_else(|_| "".to_owned());
            let ns = util::ns(&src).unwrap_or_else(|| conn.user_ns.clone());

            conn.completions
                .write(&clojure::eval(&clojure::completions(&ns), &ns, &conn.lang))?;
        }

        Ok(())
    }
}
