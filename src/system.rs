use clojure;
use editor::{Event, Server};
use pool::Pool;
use regex::Regex;
use result::Result;
use std::net::SocketAddr;
use std::sync::mpsc;

static DEFAULT_TAG: &str = "Conjure";

pub struct System {
    pool: Pool,
    server: Server,
}

impl System {
    pub fn start() -> Result<Self> {
        info!("Starting system");
        let (tx, rx) = mpsc::channel();
        let mut system = Self {
            pool: Pool::new(),
            server: Server::start(tx)?,
        };

        info!("Starting server event loop");
        for event in rx.iter() {
            match event {
                Ok(event) => {
                    info!("Event from server: {}", event);

                    match event {
                        Event::Quit => break,
                        Event::List => system.handle_list(),
                        Event::ShowLog => system.handle_show_log(),
                        Event::Connect {
                            key,
                            addr,
                            expr,
                            lang,
                        } => system.handle_connect(&key, addr, &expr, lang),
                        Event::Disconnect { key } => system.handle_disconnect(&key),
                        Event::Eval { code } => system.handle_eval(&code),
                        Event::GoToDefinition { name } => system.handle_go_to_definition(&name),
                        Event::UpdateCompletions => system.handle_update_completions(),
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
        if self.pool.has_connections() {
            let lines: Vec<String> = self
                .pool
                .iter()
                .map(|(key, conn)| {
                    format!(
                        ";; [{}] {} for files matching '{}'",
                        key, conn.addr, conn.expr
                    )
                })
                .collect();

            self.server.log_writelns(DEFAULT_TAG, &lines);
        } else {
            self.server
                .log_writeln(DEFAULT_TAG, ";; No connections".to_owned());
        }
    }

    fn handle_show_log(&mut self) {
        if let Err(msg) = self.server.display_or_create_log_window() {
            self.server
                .err_writeln(&format!("Failed to show the log window: {}", msg))
        }
    }

    fn handle_connect(&mut self, key: &str, addr: SocketAddr, expr: &Regex, lang: clojure::Lang) {
        if let Err(msg) = self.pool.connect(&key, &self.server, addr, &expr, lang) {
            self.server
                .err_writeln(&format!("[{}] Connection error: {}", key, msg))
        } else {
            self.server
                .log_writeln(DEFAULT_TAG, format!(";; [{}] Connected", key));
        }
    }

    fn handle_disconnect(&mut self, key: &str) {
        if let Err(msg) = self.pool.disconnect(&key) {
            self.server
                .err_writeln(&format!("[{}] Disconnection error: {}", key, msg))
        } else {
            self.server
                .log_writeln(DEFAULT_TAG, format!(";; [{}] Disconnected", key));
        }
    }

    fn handle_eval(&mut self, code: &str) {
        lazy_static! {
            static ref whitespace_re: Regex =
                Regex::new(r"\s+").expect("failed to compile whitespace regex");
        }

        let ctx = self.server.context();
        let flat_code = whitespace_re.replace_all(code, " ").to_string();
        let max_sample_length = 70;
        let sample = if flat_code.len() >= max_sample_length {
            format!("{}...", flat_code.split_at(max_sample_length).0)
        } else {
            flat_code
        };

        match self.pool.eval(code, ctx) {
            Ok(names) => self.server.log_writeln(
                &format!("eval => {}", names.join(", ")),
                format!(";; {}", sample),
            ),
            Err(msg) => self.server.err_writeln(&format!("Eval error: {}", msg)),
        }
    }

    fn handle_go_to_definition(&mut self, name: &str) {
        let ctx = self.server.context();

        if let Err(msg) = self.pool.go_to_definition(name, ctx) {
            self.server
                .err_writeln(&format!("Definition lookup error: {}", msg));
        }
    }

    fn handle_update_completions(&mut self) {
        let ctx = self.server.context();

        if let Err(msg) = self.pool.update_completions(ctx) {
            self.server
                .err_writeln(&format!("Completion error: {}", msg))
        }
    }
}
