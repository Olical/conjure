extern crate conjure;
extern crate neovim_lib;
extern crate regex;

use conjure::server;
use conjure::server::Event;
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();
    let mut server = server::Server::new();
    server.start(tx);

    for event in rx.iter() {
        match event {
            Event::Quit => break,
            Event::Connect { addr, expr } => {
                eprintln!("connected to {} for files matching {}", addr, expr)
            }
        }
    }
}
