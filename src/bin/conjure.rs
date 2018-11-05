#[macro_use]
extern crate log;
extern crate simplelog;

extern crate conjure;

use conjure::server;
use conjure::server::Event;
use simplelog::*;
use std::env;
use std::fs::File;
use std::io;
use std::sync::mpsc;

fn main() {
    initialise_logger();

    info!("==========================");

    if let Err(msg) = start() {
        error!("Error from start: {}", msg);
    }
}

fn start() -> Result<(), io::Error> {
    info!("Starting Neovim RPC server");
    let (tx, rx) = mpsc::channel();
    let mut server = server::Server::start(tx)?;

    info!("Starting event channel loop");
    for event in rx.iter() {
        match event {
            Ok(event) => {
                info!("Event from server: {}", event);

                match event {
                    Event::Quit => break,
                    Event::Connect { addr, expr } => server.echo(&format!(
                        "Connected to {} for files matching {}",
                        addr, expr
                    )),
                }
            }
            Err(msg) => {
                error!("Error from server: {}", msg);
                server.echoerr(&format!("Error parsing command: {}", msg))
            }
        }
    }

    Ok(())
}

fn initialise_logger() {
    if let Ok(mut path) = env::current_exe() {
        path.set_file_name("conjure.log");

        if let Ok(log_file) = File::create(path) {
            let _ = WriteLogger::init(LevelFilter::Trace, Config::default(), log_file);
        }
    }
}
