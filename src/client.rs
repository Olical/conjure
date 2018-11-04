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

pub struct Client {
    itx: mpsc::Sender<String>,
}

impl Client {
    pub fn connect(
        addr: &'static str,
        tx: mpsc::Sender<Result<Value, String>>,
    ) -> io::Result<Self> {
        match net::TcpStream::connect(addr) {
            Ok(stream) => {
                let (itx, irx) = mpsc::channel();

                thread::spawn(move || {
                    let reader = io::BufReader::new(stream);

                    for line in reader.lines() {
                        match line {
                            Ok(line) => {
                                let _parser = edn::parser::Parser::new(&line);
                                tx.send(Err(String::from("foo")));
                            }
                            Err(msg) => {
                                tx.send(Err(String::from("bar")));
                            }
                        }
                    }
                });

                Ok(Client { itx })
            }
            Err(msg) => Err(msg),
        }
    }

    pub fn eval(&mut self, code: &str) {
        match self.itx.send(format!("{}\n", code)) {
            Err(msg) => error!("error sending to itx: {}", msg),
            _ => (),
        }
    }
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
