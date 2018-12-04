use regex::Regex;
use result::{error, Result};
use std::env::current_exe;
use std::fs::File;
use std::io::prelude::*;
use std::path::PathBuf;

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "couldn't convert path to string: {:?}", path)]
    NoPathString { path: PathBuf },
}

pub fn escape_quotes(s: &str) -> String {
    s.replace("\\", "\\\\").replace("\"", "\\\"")
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

pub fn clojure_src(file: &str) -> Result<String> {
    let path = clojure_path(file)?;

    let mut file = File::open(path)?;
    let mut src = String::new();
    file.read_to_string(&mut src)?;
    Ok(src)
}

pub fn clojure_ns(source: &str) -> Option<String> {
    lazy_static! {
        static ref clojure_ns_re: Regex = Regex::new(r"\(\s*ns\s+(\D[[[:word:]]\.\*\+!\-'?]*)\s*")
            .expect("failed to compile ns regex");
    }

    if let Some(cap) = clojure_ns_re.captures_iter(source).next() {
        cap.get(1).map(|ns| ns.as_str().to_owned())
    } else {
        None
    }
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
        assert_eq!(clojure_ns("(ns foo.my-ns)").unwrap(), "foo.my-ns");
        assert_eq!(clojure_ns("(ns foo.my-ns))").unwrap(), "foo.my-ns");
        assert_eq!(
            clojure_ns("(ns foo.my-ns \"docs\") :boop").unwrap(),
            "foo.my-ns"
        );
        assert!(clojure_ns("nope").is_none());
        assert_eq!(
            clojure_ns("( \n\n \n ns \n\n   \n foo__123.my-ns!?. \n\"lol docs?\" ¯\\_(ツ)_/¯)")
                .unwrap(),
            "foo__123.my-ns!?."
        );
    }
}
