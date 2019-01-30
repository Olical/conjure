#[macro_use]
extern crate log;
extern crate simplelog;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate lazy_static;

extern crate chrono;
extern crate edn;
extern crate neovim_lib;
extern crate regex;

pub mod clojure;
pub mod editor;
pub mod pool;
pub mod repl;
pub mod result;
pub mod system;
pub mod util;

use simplelog::*;
use std::env;
use std::fs::File;
use system::System;

fn main() {
    let args: Vec<String> = env::args().collect();

    if let Some(logging) = args.get(1) {
        if logging == "1" {
            initialise_logger();
        }
    } else {
        initialise_logger();
        warn!("Initialised the logger because I couldn't check if I should initialise it or not (first CLI arg 1/0)");
    }

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
