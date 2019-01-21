use regex::Regex;
use std::io::prelude::*;

pub fn escape_quotes(s: &str) -> String {
    s.replace("\\", "\\\\").replace("\"", "\\\"")
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

pub fn parse_completions(completions_str: &str) -> Option<Vec<&str>> {
    lazy_static! {
        static ref completions_re: Regex =
            Regex::new(r#"^\((.*)\)$"#).expect("failed to compile completions regex");
    }

    if let Some(cap) = completions_re.captures_iter(completions_str).next() {
        match cap.get(1) {
            Some(completions) => Some(completions.as_str().split(" ").collect()),
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
}
