use std::io;
use std::io::prelude::*;
use std::net;
use std::sync::mpsc;
use std::thread;

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

type Sender = mpsc::Sender<String>;
type Receiver = mpsc::Receiver<Value>;

// pub fn connect(addr: &'static str) -> Result<(Sender, Receiver), String> {
//     match net::TcpStream::connect(addr) {
//         Ok(stream) => {
//             let (tx, rx) = mpsc::channel();
//             let itx = tx.clone();

//             thread::spawn(move || {
//                 let reader = io::BufReader::new(stream);

//                 for line in reader.lines() {
//                     match line {
//                         Ok(line) => {
//                             let _parser = edn::parser::Parser::new(&line);
//                             itx.send(Value::Return(String::from(line)));
//                         }
//                         Err(msg) => {
//                             itx.send(Value::Return(format!("ohno: {}", msg)));
//                         }
//                     }
//                 }
//             });

//             Ok((tx, rx))
//         }
//         Err(msg) => Err(format!("Couldn't connect to `{}`: {}", addr, msg)),
//     }
// }

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
