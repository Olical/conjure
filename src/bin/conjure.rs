#[macro_use]
extern crate log;
extern crate simplelog;

extern crate conjure;

use conjure::server;
use conjure::server::Event;
use simplelog::*;
use std::env;
use std::fs::File;
use std::sync::mpsc;

fn main() {
    initialise_logger();

    info!("starting Conjure");
    let (tx, rx) = mpsc::channel();

    info!("starting Neovim RPC server");
    let mut server = server::Server::new();
    server.start(tx);

    info!("starting event channel loop");
    for event in rx.iter() {
        info!("got event: {}", event);

        match event {
            Event::Quit => break,
            Event::Connect { addr, expr } => {
                eprintln!("connected to {} for files matching {}", addr, expr)
            }
        }
    }
}

fn initialise_logger() {
    if let Ok(mut path) = env::current_exe() {
        path.set_file_name("conjure.log");

        if let Ok(log_file) = File::create(path) {
            match WriteLogger::init(LevelFilter::Trace, Config::default(), log_file) {
                _ => (),
            }
        }
    }
}
