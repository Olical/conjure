use bufstream::BufStream;
use edn::parser::Parser;
use edn::Value;
use std::io;
use std::io::prelude::*;
use std::net::TcpStream;

pub enum Response {
    Return(String),
    Out(String),
    Tap(String),
    Error(String),
}

fn keyword(name: &str) -> Value {
    Value::Keyword(name.to_owned())
}

impl Response {
    fn from(value: Value) -> Result<Self, String> {
        if let Value::Map(msg) = value {
            let tag = msg
                .get(&keyword("tag"))
                .ok_or_else(|| format!("failed to get tag from: {:?}", msg))?;

            let val = msg
                .get(&keyword("val"))
                .ok_or_else(|| format!("failed to get val from: {:?}", msg))?;

            if let (Value::Keyword(tag), Value::String(val)) = (tag, val) {
                let val = val.to_owned();

                match tag.as_ref() {
                    "out" => Ok(Response::Out(val)),
                    "ret" => Ok(Response::Return(val)),
                    "err" => Ok(Response::Error(val)),
                    "tap" => Ok(Response::Tap(val)),
                    _ => Err(format!("unknown tag type: {}", tag)),
                }
            } else {
                Err(format!(
                    "tag should be a keyword and val should be a string: {:?}",
                    msg
                ))
            }
        } else {
            Err(format!("is not a map: {:?}", value))
        }
    }
}

pub struct Client {
    stream: BufStream<TcpStream>,
}

impl Client {
    pub fn connect(addr: &str) -> Result<Self, String> {
        let raw_stream = TcpStream::connect(addr)
            .map_err(|msg| format!("Couldn't connect to `{}`: {}", addr, msg))?;

        Ok(Self {
            stream: BufStream::new(raw_stream),
        })
    }

    pub fn read(&mut self) -> Result<Response, String> {
        let mut buf = String::new();

        self.stream
            .read_line(&mut buf)
            .map_err(|msg| format!("failed to read line: {}", msg))?;

        let mut parser = Parser::new(&buf);

        match parser.read() {
            Some(Ok(value)) => Response::from(value),
            Some(Err(msg)) => Err(format!("failed to parse response as EDN: {:?}", msg)),
            None => Err("didn't get anything from the EDN parser".to_owned()),
        }
    }

    pub fn write(&mut self, code: &str) -> io::Result<usize> {
        self.stream.write(format!("{}\n", code).as_bytes())
    }
}
