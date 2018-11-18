use edn::parser::Parser;
use edn::Value;
use ohno::{Error, Result};
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

#[derive(Debug, Fail)]
enum ResponseError {
    #[fail(
        display = "missing keyword `{:?}` in REPL response: {:?}",
        keyword,
        value
    )]
    MissingKeyword { value: Value, keyword: Value },

    #[fail(display = "unknown tag: {:?}", tag)]
    UnknownTag { tag: String },

    #[fail(display = "response type was not as expected: {:?}", value)]
    TypeMismatch { value: Value },
}

impl Response {
    fn from(value: Value) -> Result<Self> {
        if let Value::Map(msg) = value {
            let tag_kw = keyword("tag");
            let tag = msg
                .get(&tag_kw)
                .ok_or_else(|| ResponseError::MissingKeyword {
                    keyword: tag_kw,
                    value,
                })?;

            let val_kw = keyword("val");
            let val = msg
                .get(&val_kw)
                .ok_or_else(|| ResponseError::MissingKeyword {
                    keyword: val_kw,
                    value,
                })?;

            if let (Value::Keyword(tag), Value::String(val)) = (tag, val) {
                let val = val.to_owned();

                match tag.as_ref() {
                    "ret" => Ok(Response::Ret(val)),
                    "tap" => Ok(Response::Tap(val)),
                    "out" => Ok(Response::Out(val)),
                    "err" => Ok(Response::Err(val)),
                    _ => Err(Error::from(ResponseError::UnknownTag {
                        tag: tag.to_owned(),
                    })),
                }
            } else {
                Err(Error::from(ResponseError::TypeMismatch { value }))
            }
        } else {
            Err(Error::from(ResponseError::TypeMismatch { value }))
        }
    }
}

pub struct Client {
    stream: TcpStream,
}

impl Client {
    pub fn connect(addr: SocketAddr) -> Result<Self> {
        let stream = TcpStream::connect_timeout(&addr, Duration::from_secs(5))?;
        stream.set_write_timeout(Some(Duration::from_secs(5)))?;

        Ok(Self { stream })
    }

    pub fn try_clone(&self) -> Result<Self> {
        let stream = self.stream.try_clone()?;

        Ok(Self { stream })
    }

    pub fn responses(self) -> Box<Iterator<Item = Result<Response>>> {
        let reader = BufReader::new(self.stream);

        let responses = reader.lines().map(|line| {
            line.and_then(|line| {
                Parser::new(&line)
                    .read()
                    .ok_or("nothing to read".to_owned())
            }).and_then(|value| value)
            .and_then(|value| Response::from(value))
        });

        Box::new(responses)
    }

    pub fn write(&mut self, code: &str) -> Result<()> {
        self.stream
            .write_all(format!("{}\n", code).as_bytes())
            .map_err(|msg| format!("error on write: {}", msg))?;

        self.stream
            .flush()
            .map_err(|msg| format!("error on flush: {}", msg))?;

        Ok(())
    }
}
