use bufstream::BufStream;
use edn::parser::Parser;
use edn::Value;
use std::io;
use std::io::prelude::*;
use std::net::{SocketAddr, TcpStream};
use std::sync::mpsc;
use std::thread;
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
    stream: BufStream<TcpStream>,
}

impl Client {
    pub fn connect(addr: SocketAddr) -> Result<Self, String> {
        let raw_stream = TcpStream::connect_timeout(&addr, Duration::from_secs(5))
            .map_err(|msg| format!("couldn't connect to {}: {}", addr, msg))?;

        raw_stream
            .set_write_timeout(Some(Duration::from_secs(5)))
            .map_err(|msg| format!("failed to set write timeout: {}", msg))?;

        raw_stream
            .set_read_timeout(Some(Duration::from_millis(200)))
            .or_else(|msg| Err(format!("failed to set read timeout: {}", msg)))?;

        Ok(Self {
            stream: BufStream::new(raw_stream),
        })
    }

    pub fn read(&mut self) -> Option<Result<Response, String>> {
        let mut buf = String::new();

        if let Err(msg) = self.stream.read_line(&mut buf) {
            error!("Failed to read line from stream: {}", msg);
            return None;
        }

        let mut parser = Parser::new(&buf);

        Some(match parser.read() {
            Some(Ok(value)) => Response::from(value),
            Some(Err(msg)) => Err(format!("failed to parse response as EDN: {:?}", msg)),
            None => Err("didn't get anything from the EDN parser".to_owned()),
        })
    }

    pub fn write(&mut self, code: &str) -> io::Result<()> {
        self.stream.write_all(format!("{}\n", code).as_bytes())?;
        self.stream.flush()
    }

    pub fn channels(mut self) -> (Writer, Reader) {
        let (w_tx, w_rx) = mpsc::channel();
        let (r_tx, r_rx) = mpsc::channel();

        thread::spawn(move || loop {
            for value in w_rx.try_iter() {
                let value: String = value;

                if let Err(msg) = self.write(&value) {
                    error!("Error writing from Sender channel: {}", msg);
                }
            }

            if let Some(resp) = self.read() {
                if let Err(msg) = r_tx.send(resp) {
                    error!("Error while sending to Reader channel: {}", msg);
                }
            }
        });

        (w_tx, r_rx)
    }
}

pub type Writer = mpsc::Sender<String>;
pub type Reader = mpsc::Receiver<Result<Response, String>>;
