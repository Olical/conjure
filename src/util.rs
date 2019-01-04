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

pub fn parse_location(loc_str: &str) -> Option<(String, i64, i64)> {
    lazy_static! {
        static ref loc_re: Regex =
            Regex::new(r#"^\["(.*)" (\d+) (\d+)\]$"#).expect("failed to compile location regex");
    }

    if let Some(cap) = loc_re.captures_iter(loc_str).next() {
        match (cap.get(1), cap.get(2), cap.get(3)) {
            (Some(path), Some(row), Some(col)) => Some((
                path.as_str().to_owned(),
                row.as_str().parse().unwrap_or(1),
                col.as_str().parse().unwrap_or(1),
            )),
            _ => {
                warn!("Couldn't extract capture groups: {}", loc_str);
                None
            }
        }
    } else {
        warn!("Result didn't match expression: {}", loc_str);
        None
    }
}

pub fn parse_completions(completions_str: &str) -> Option<String> {
    lazy_static! {
        static ref completions_re: Regex =
            Regex::new(r#"^"(\[.*\])"$"#).expect("failed to compile completions regex");
    }

    if let Some(cap) = completions_re.captures_iter(completions_str).next() {
        match cap.get(1) {
            Some(completions) => Some(completions.as_str().to_owned()),
            _ => {
                warn!("Couldn't extract capture groups: {}", completions_str);
                None
            }
        }
    } else {
        warn!("Result didn't match expression: {}", completions_str);
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
