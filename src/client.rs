use bufstream::BufStream;
use std::io;
use std::io::prelude::*;
use std::net::TcpStream;

pub enum Value {
    Return(String),
    Out(String),
    Tap(String),
    Error(String),
}

impl Value {
    fn from(_value: edn::Value) -> Self {
        Value::Return("foo".to_owned())
    }
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
    stream: BufStream<TcpStream>,
}

impl Client {
    pub fn connect(addr: &'static str) -> Result<Client, String> {
        match TcpStream::connect(addr) {
            Ok(raw_stream) => {
                let stream = BufStream::new(raw_stream);
                Ok(Client { stream })
            }
            Err(msg) => Err(format!("Couldn't connect to `{}`: {}", addr, msg)),
        }
    }

    pub fn read(&mut self) -> Result<Value, String> {
        let mut buf = String::new();

        self.stream
            .read_line(&mut buf)
            .map_err(|msg| format!("failed to read line: {}", msg))?;

        let mut parser = edn::parser::Parser::new(&buf);

        match parser.read() {
            Some(Ok(value)) => Ok(Value::from(value)),
            Some(Err(msg)) => Err(format!("failed to parse response as EDN: {:?}", msg)),
            None => Err("didn't get anything from the EDN parser".to_owned()),
        }
    }

    pub fn write(&mut self, code: &str) -> io::Result<usize> {
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
