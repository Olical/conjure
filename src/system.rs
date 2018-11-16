use editor::{Event, Server};
use pool::Pool;
use regex::Regex;
use std::net::SocketAddr;
use std::sync::mpsc;

static DEFAULT_TAG: &str = "Conjure";

// TODO Implement a heartbeat for connections.
// TODO Never suppress errors in repl/editor, flow them ALL up to system.

pub struct System {
    pool: Pool,
    server: Server,
}

impl System {
    pub fn start() -> Result<Self, String> {
        info!("Starting system");
        let (tx, rx) = mpsc::channel();
        let mut system = Self {
            pool: Pool::new(),
            server: Server::start(tx)?,
        };

        system
            .server
            .log_writeln(DEFAULT_TAG, ";; Welcome!".to_owned());

        info!("Starting server event loop");
        for event in rx.iter() {
            match event {
                Ok(event) => {
                    info!("Event from server: {}", event);

                    match event {
                        Event::Quit => break,
                        Event::List => system.handle_list(),
                        Event::ShowLog => system.handle_show_log(),
                        Event::Connect { key, addr, expr } => {
                            system.handle_connect(key, addr, expr)
                        }
                        Event::Disconnect { key } => system.handle_disconnect(key),
                        Event::Eval { code, path } => system.handle_eval(code, path),
                    }
                }
                Err(msg) => system
                    .server
                    .err_writeln(&format!("Error parsing command: {}", msg)),
            }
        }

        info!("Broke out of server event loop");

        Ok(system)
    }

    fn handle_list(&mut self) {
        if self.pool.is_empty() {
            self.server
                .log_writeln(DEFAULT_TAG, ";; No connections".to_owned());
        } else {
            let lines: Vec<String> = self
                .pool
                .iter()
                .map(|(key, conn)| {
                    format!(
                        ";; [{}] {} for files matching '{}'",
                        key, conn.addr, conn.expr
                    )
                }).collect();

            self.server.log_writelns(DEFAULT_TAG, &lines);
        }
    }

    fn handle_show_log(&mut self) {
        if let Err(msg) = self.server.display_or_create_log_window() {
            self.server
                .err_writeln(&format!("Failed to show the log window: {}", msg))
        }
    }

    fn handle_connect(&mut self, key: String, addr: SocketAddr, expr: Regex) {
        if let Err(msg) = self.pool.connect(&key, &self.server, addr, expr) {
            self.server
                .err_writeln(&format!("[{}] Connection error: {}", key, msg))
        } else {
            self.server
                .log_writeln(DEFAULT_TAG, format!(";; [{}] Connected", key));
        }
    }

    fn handle_disconnect(&mut self, key: String) {
        if let Err(msg) = self.pool.disconnect(&key) {
            self.server
                .err_writeln(&format!("[{}] Disconnection error: {}", key, msg))
        } else {
            self.server
                .log_writeln(DEFAULT_TAG, format!("[{}] Disconnected", key));
        }
    }

    fn handle_eval(&mut self, code: String, path: String) {
        if let Err(msg) = self.pool.eval(&code, &path) {
            self.server.err_writeln(&format!("Eval error: {}", msg));
        }
    }
}
