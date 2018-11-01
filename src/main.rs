extern crate edn;
extern crate neovim_lib as neovim;
extern crate regex;

mod client;
mod server;

use std::process;

fn main() {
    server::start(|event| match event {
        server::Request::Exit => process::exit(0),
        server::Request::Connect { addr, expr } => {
            eprintln!("Connect to {} for {}", addr, expr);
            Ok(neovim::Value::Nil)
        }
        server::Request::Error(msg) => {
            eprintln!("Error while handling request: {}", msg);
            Ok(neovim::Value::Nil)
        }
    });
}
