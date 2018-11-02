extern crate edn;
extern crate neovim_lib;
extern crate regex;

mod client;
mod server;

use neovim_lib::Value;
use server::Request;
use std::process;

fn main() {
    server::start(|event| match event {
        Request::Exit => process::exit(0),
        Request::Connect { addr, expr } => Ok(Value::String(
            format!("Connected to {} for files matching {}", addr, expr).into(),
        )),
    });
}
