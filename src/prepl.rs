use std::io;
use std::io::prelude::*;
use std::net;

pub fn start() {
    if let Ok(mut stream) = net::TcpStream::connect("127.0.0.1:5555") {
        println!("Connected!");

        let code = "(prn \"Hello from Rust!\")";
        println!("Evaluating `{}` through a Clojure socket pREPL", code);

        stream.write(format!("{}\n", code).as_bytes()).unwrap();

        let reader = io::BufReader::new(stream);

        for line in reader.lines() {
            println!("=> {}", line.unwrap());
        }
    } else {
        println!("Nope");
    }
}
