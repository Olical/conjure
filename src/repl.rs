use edn::parser::Parser;
use edn::Value;
use result::{error, Result};
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
enum Error {
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

    #[fail(display = "empty result from EDN parse")]
    EmptyParseResult,

    #[fail(display = "error parsing EDN: {:?}", err)]
    ParseFailed { err: edn::parser::Error },
}

impl Response {
    fn from(value: Value) -> Result<Self> {
        let e_value = value.clone();

        if let Value::Map(msg) = value {
            let tag_kw = keyword("tag");
            let tag = msg.get(&tag_kw).ok_or_else(|| Error::MissingKeyword {
                keyword: tag_kw,
                value: e_value.clone(),
            })?;

            let val_kw = keyword("val");
            let val = msg.get(&val_kw).ok_or_else(|| Error::MissingKeyword {
                keyword: val_kw,
                value: e_value.clone(),
            })?;

            if let (Value::Keyword(tag), Value::String(val)) = (tag, val) {
                let val = val.to_owned();

                match tag.as_ref() {
                    "ret" => Ok(Response::Ret(val)),
                    "tap" => Ok(Response::Tap(val)),
                    "out" => Ok(Response::Out(val)),
                    "err" => Ok(Response::Err(val)),
                    _ => Err(error(Error::UnknownTag {
                        tag: tag.to_owned(),
                    })),
                }
            } else {
                Err(error(Error::TypeMismatch {
                    value: e_value.clone(),
                }))
            }
        } else {
            Err(error(Error::TypeMismatch { value }))
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

    pub fn responses(self) -> Result<Box<Iterator<Item = Result<Response>>>> {
        let stream = self.stream.try_clone().map_err(error)?;
        let reader = BufReader::new(stream);

        let responses = reader.lines().map(|line| {
            line.map(|line| match Parser::new(&line).read() {
                Some(Ok(value)) => Response::from(value),
                Some(Err(err)) => Err(error(Error::ParseFailed { err })),
                None => Err(error(Error::EmptyParseResult)),
            }).map_err(error)
            .and_then(|x| x)
        });

        Ok(Box::new(responses))
    }

    pub fn write(&mut self, code: &str) -> Result<()> {
        self.stream.write_all(format!("{}\n", code).as_bytes())?;
        self.stream.flush()?;

        Ok(())
    }

    pub fn wait(&mut self) -> Result<()> {
        self.stream.read_exact(&mut [])?;
        Ok(())
    }

    pub fn quit(&mut self) -> Result<()> {
        self.write(":repl/quit")?;
        self.wait()
    }
}

impl Drop for Client {
    fn drop(&mut self) {
        if let Err(msg) = self.quit() {
            error!("Failed to quit REPL cleanly: {}", msg);
        }
    }
}
