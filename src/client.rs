use std::io;
use std::io::prelude::*;
use std::net;

enum Value {
    Return,
    Out,
    Tap,
    Error,
}

// {:tag :ret
//  :val val ;;eval result
//  :ns ns-name-string
//  :ms long ;;eval time in milliseconds
//  :form string ;;iff successfully read
// }
// {:tag :out
//  :val string} ;chars from during-eval *out*
// {:tag :err
//  :val string} ;chars from during-eval *err*
// {:tag :tap
//  :val val} ;values from tap>

trait Client {
    fn new(addr: &'static str) -> Self;
    fn write(&mut self, &str) -> io::Result<usize>;
    fn iter(&mut self) -> Iterator<Item = Result<edn::Value, edn::parser::Error>>;
}

pub fn start() {
    if let Ok(mut stream) = net::TcpStream::connect("127.0.0.1:5555") {
        println!("Connected!");

        let code = "(prn \"Hello from Rust!\")";
        println!("Evaluating `{}` through a Clojure socket pREPL", code);

        stream.write(format!("{}\n", code).as_bytes()).unwrap();

        let reader = io::BufReader::new(stream);

        for line in reader.lines() {
            let s = line.unwrap();
            let mut parser = edn::parser::Parser::new(&s[..]);
            println!("=> {:?}", parser.read());
        }
    } else {
        println!("Nope");
    }
}
