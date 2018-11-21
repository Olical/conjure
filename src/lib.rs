#[macro_use]
extern crate log;

#[macro_use]
extern crate failure;

extern crate chrono;
extern crate edn;
extern crate neovim_lib;
extern crate regex;

pub mod editor;
pub mod pool;
pub mod repl;
pub mod result;
pub mod system;
pub mod util;
