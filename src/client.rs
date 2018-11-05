use std::io;
use std::io::prelude::*;
use std::net::TcpStream;

pub enum Value {
    Return(String),
    Out(String),
    Tap(String),
    Error(String),
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

pub struct Client {
    stream: TcpStream,
}

impl Client {
    pub fn connect(addr: &'static str) -> Result<Client, String> {
        match TcpStream::connect(addr) {
            Ok(stream) => Ok(Client { stream }),
            Err(msg) => Err(format!("Couldn't connect to `{}`: {}", addr, msg)),
        }
    }

    pub fn eval(&mut self, code: &str) -> io::Result<usize> {
        self.stream.write(format!("{}\n", code).as_bytes())
    }
}

// pub fn start() {
//     if let Ok(mut stream) = net::TcpStream::connect("127.0.0.1:5555") {
//         println!("Connected!");

//         let code = "(prn \"Hello from Rust!\")";
//         println!("Evaluating `{}` through a Clojure socket pREPL", code);

//         stream.write(format!("{}\n", code).as_bytes()).unwrap();

//         let reader = io::BufReader::new(stream);

//         for line in reader.lines() {
//             let s = line.unwrap();
//             let mut parser = edn::parser::Parser::new(&s[..]);
//             println!("=> {:?}", parser.read());
//         }
//     } else {
//         println!("Nope");
//     }
// }
