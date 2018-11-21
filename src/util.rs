use edn::parser::Parser;
use edn::Value;
use result::{error, Result};
use std::env::current_exe;
use std::path::PathBuf;

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "couldn't convert path to string: {:?}", path)]
    NoPathString { path: PathBuf },

    #[fail(display = "couldn't find namespace")]
    NoNamespace,

    #[fail(display = "error parsing source: {:?}", err)]
    ParseError { err: edn::parser::Error },
}

pub fn escape_quotes(s: &str) -> String {
    s.replace("\"", "\\\"")
}

pub fn clojure_path(file: &str) -> Result<String> {
    let prefix = "../../clojure/";
    let mut exe = current_exe()?;
    exe.pop();

    let path = exe.join(prefix).join(file).canonicalize()?;

    match path.to_str() {
        Some(path) => Ok(path.to_owned()),
        None => Err(error(Error::NoPathString {
            path: path.to_owned(),
        })),
    }
}

// TODO Make this neater?
pub fn clojure_namespace(source: &str) -> Result<String> {
    let form = match Parser::new(&source).read() {
        Some(Ok(form)) => Ok(form),
        Some(Err(err)) => Err(Error::ParseError { err }),
        None => Err(Error::NoNamespace),
    }?;

    let list = match form {
        Value::List(list) => Ok(list),
        _ => Err(Error::NoNamespace),
    }?;

    if let (Some(Value::Symbol(symbol)), Some(Value::Symbol(namespace))) =
        (list.get(0), list.get(1))
    {
        if symbol == "ns" {
            return Ok(namespace.to_owned());
        }
    }

    Err(error(Error::NoNamespace))
}

// TODO Write and slightly test this function.
// pub fn clojure_file_namespace(path: &str) -> Result<String> {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn escaping_quotes() {
        assert_eq!(escape_quotes("'foo'"), "'foo'");
        assert_eq!(escape_quotes("\"foo\""), "\\\"foo\\\"");
    }

    #[test]
    fn parsing_a_clojure_ns() {
        assert_eq!(clojure_namespace("(ns foo.my-ns)").unwrap(), "foo.my-ns");
        assert_eq!(
            clojure_namespace("(ns foo.my-ns \"docs\") :boop").unwrap(),
            "foo.my-ns"
        );

        match clojure_namespace("nope") {
            Err(_) => assert!(true),
            Ok(namespace) => panic!("expected an error, got a namespace: {}", namespace),
        }
    }
}
