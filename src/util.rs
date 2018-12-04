use regex::Regex;
use result::Result;
use std::fs::File;
use std::io::prelude::*;

pub fn escape_quotes(s: &str) -> String {
    s.replace("\\", "\\\\").replace("\"", "\\\"")
}

pub fn slurp(path: &str) -> Result<String> {
    let mut file = File::open(path)?;
    let mut src = String::new();
    file.read_to_string(&mut src)?;
    Ok(src)
}

pub fn ns(source: &str) -> Option<String> {
    lazy_static! {
        static ref ns_re: Regex = Regex::new(r"\(\s*ns\s+(\D[[[:word:]]\.\*\+!\-'?]*)\s*")
            .expect("failed to compile ns regex");
    }

    if let Some(cap) = ns_re.captures_iter(source).next() {
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
    fn parsing_a_ns() {
        assert_eq!(ns("(ns foo.my-ns)").unwrap(), "foo.my-ns");
        assert_eq!(ns("(ns foo.my-ns))").unwrap(), "foo.my-ns");
        assert_eq!(ns("(ns foo.my-ns \"docs\") :boop").unwrap(), "foo.my-ns");
        assert!(ns("nope").is_none());
        assert_eq!(
            ns("( \n\n \n ns \n\n   \n foo__123.my-ns!?. \n\"lol docs?\" ¯\\_(ツ)_/¯)").unwrap(),
            "foo__123.my-ns!?."
        );
    }
}
