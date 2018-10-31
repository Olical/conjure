extern crate edn;
extern crate neovim_lib as neovim;

mod client;
mod server;

use std::process;

fn main() {
    server::start(|event| match event {
        server::Message::Exit => process::exit(0),
        server::Message::Connect { addr, expr } => {
            eprintln!("Connect to {} for {}", addr, expr);
            Ok(neovim::Value::Nil)
        }
        server::Message::Unknown(name) => {
            eprintln!("Unknown command: {}", name);
            Ok(neovim::Value::Nil)
        }
    });
}
