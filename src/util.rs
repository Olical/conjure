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

pub fn clojure_namespace(source: &str) -> Option<String> {
    lazy_static! {
        static ref clojure_namespace_re: Regex =
            Regex::new(r"\(\s*ns\s+(\D[[[:word:]]\.\*\+!\-'?]*)\s*")
                .expect("failed to compile namespace regex");
    }

    for cap in clojure_namespace_re.captures_iter(source) {
        return cap.get(1).map(|ns| ns.as_str().to_owned());
    }

    None
}

pub fn clojure_file_namespace(path: &str) -> Result<Option<String>> {
    let mut file = File::open(path)?;

    let mut source = String::new();
    file.read_to_string(&mut source)?;

    Ok(clojure_namespace(&source))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parsing_a_clojure_ns() {
        assert_eq!(clojure_namespace("(ns foo.my-ns)").unwrap(), "foo.my-ns");
        assert_eq!(clojure_namespace("(ns foo.my-ns))").unwrap(), "foo.my-ns");
        assert_eq!(
            clojure_namespace("(ns foo.my-ns \"docs\") :boop").unwrap(),
            "foo.my-ns"
        );
        assert!(clojure_namespace("nope").is_none());
        assert_eq!(
            clojure_namespace(
                "( \n\n \n ns \n\n   \n foo__123.my-ns!?. \n\"lol docs?\" ¯\\_(ツ)_/¯)"
            ).unwrap(),
            "foo__123.my-ns!?."
        );
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
