use edn::parser::Parser;
use edn::Value;
use std::io::prelude::*;
use std::io::BufReader;
use std::net::{SocketAddr, TcpStream};
use std::time::Duration;

#[derive(Debug)]
pub enum Response {
    Ret(String),
    Tap(String),
    Out(String),
    Err(String),
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
                    "ret" => Ok(Response::Ret(val)),
                    "tap" => Ok(Response::Tap(val)),
                    "out" => Ok(Response::Out(val)),
                    "err" => Ok(Response::Err(val)),
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
    stream: TcpStream,
}

impl Client {
    pub fn connect(addr: SocketAddr) -> Result<Self, String> {
        let stream = TcpStream::connect_timeout(&addr, Duration::from_secs(5))
            .map_err(|msg| format!("couldn't connect to {}: {}", addr, msg))?;

        stream
            .set_write_timeout(Some(Duration::from_secs(5)))
            .map_err(|msg| format!("failed to set write timeout: {}", msg))?;

        Ok(Self { stream })
    }

    pub fn try_clone(&self) -> Result<Self, String> {
        let stream = self
            .stream
            .try_clone()
            .map_err(|msg| format!("failed to clone stream: {}", msg))?;

        Ok(Self { stream })
    }

    pub fn responses(self) -> Box<Iterator<Item = Result<Response, String>>> {
        let reader = BufReader::new(self.stream);

        let responses = reader.lines().map(|line| {
            line.map_err(|msg| format!("failed to read line from client: {}", msg))
                .and_then(|line| {
                    Parser::new(&line)
                        .read()
                        .ok_or("nothing to read".to_owned())
                }).and_then(|value| {
                    value.map_err(|msg| format!("failed to parse client output: {:?}", msg))
                }).and_then(|value| Response::from(value))
        });

        Box::new(responses)
    }

    pub fn write(&mut self, code: &str) -> Result<(), String> {
        self.stream
            .write_all(format!("{}\n", code).as_bytes())
            .map_err(|msg| format!("error on write: {}", msg))?;

        self.stream
            .flush()
            .map_err(|msg| format!("error on flush: {}", msg))?;

        Ok(())
    }
}
