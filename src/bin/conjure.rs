extern crate conjure;
extern crate neovim_lib;
extern crate regex;

use conjure::server;
use conjure::server::Request;
use neovim_lib::Value;
use std::process;

fn main() {
    server::start(|event| match event {
        Request::Exit => process::exit(0),
        Request::Connect { addr, expr } => Ok(Value::from(format!(
            "Connected to {} for files matching {}",
            addr, expr
        ))),
    });

    loop {}
}
