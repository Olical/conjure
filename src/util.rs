use edn::parser::Parser;
use edn::Value;
use result::{error, Result};
use std::env::current_exe;
use std::fs::File;
use std::io::prelude::*;
use std::path::PathBuf;

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "couldn't convert path to string: {:?}", path)]
    NoPathString { path: PathBuf },

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

pub fn clojure_namespace(source: &str) -> Result<Option<String>> {
    let form = match Parser::new(&source).read() {
        Some(Ok(form)) => Ok(Some(form)),
        Some(Err(err)) => Err(Error::ParseError { err }),
        None => Ok(None),
    }?;

    if let Some(Value::List(list)) = form {
        if let (Some(Value::Symbol(symbol)), Some(Value::Symbol(namespace))) =
            (list.get(0), list.get(1))
        {
            if symbol == "ns" {
                return Ok(Some(namespace.to_owned()));
            }
        }
    }

    Ok(None)
}

pub fn clojure_file_namespace(path: &str) -> Result<Option<String>> {
    let mut file = File::open(path)?;

    let mut source = String::new();
    file.read_to_string(&mut source)?;

    clojure_namespace(&source)
}

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
        assert_eq!(
            clojure_namespace("(ns foo.my-ns)").unwrap().unwrap(),
            "foo.my-ns"
        );
        assert_eq!(
            clojure_namespace("(ns foo.my-ns \"docs\") :boop")
                .unwrap()
                .unwrap(),
            "foo.my-ns"
        );

        match clojure_namespace("nope").unwrap() {
            None => assert!(true),
            Some(namespace) => panic!("expected an error, got a namespace: {}", namespace),
        }
    }

    #[test]
    fn parsing_a_clojure_ns_from_a_file() {
        assert_eq!(
            clojure_file_namespace("clojure/conjure/repl.cljc")
                .unwrap()
                .unwrap(),
            "conjure.repl"
        );
    }
}
