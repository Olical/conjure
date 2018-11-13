#[macro_use]
extern crate log;
extern crate simplelog;

extern crate conjure;

use conjure::system::System;
use simplelog::*;
use std::env;
use std::fs::File;

fn main() {
    initialise_logger();

    info!("==============");
    info!("== Conjure! ==");
    info!("==============");

    if let Err(msg) = System::start() {
        error!("Error from start: {}", msg);
    }

    info!("Process exiting");
}

fn initialise_logger() {
    if let Ok(mut path) = env::current_exe() {
        path.set_file_name("conjure.log");

        if let Ok(log_file) = File::create(path) {
            let _ = WriteLogger::init(LevelFilter::Trace, Config::default(), log_file);
        }
    }
}
