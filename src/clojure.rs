use result::{error, Result};
use std::str::FromStr;
use util;

#[derive(Debug)]
pub enum Lang {
    Clojure,
    ClojureScript,
}

#[derive(Debug, Fail)]
enum Error {
    #[fail(display = "couldn't parse language, should be clj or cljs")]
    ParseLangError,
}

impl FromStr for Lang {
    type Err = failure::Error;

    fn from_str(lang: &str) -> Result<Self> {
        match lang {
            "clj" => Ok(Lang::Clojure),
            "cljs" => Ok(Lang::ClojureScript),
            _ => Err(error(Error::ParseLangError)),
        }
    }
}

pub fn bootstrap() -> String {
    "
    (require #?@(:clj ['clojure.repl 'clojure.main 'clojure.java.io 'clojure.string]
                 :cljs ['cljs.repl]))

    (do
      (set! *print-length* 50)
      (str \"Ready to evaluate \" #?(:clj \"Clojure\", :cljs \"ClojureScript\") \"!\"))
    ".to_owned()
}

pub fn definition(name: &str) -> String {
    format!(
        "
        (update
          (mapv (meta #'{}) [:file :line :column])
          0
          #?(:cljs identity
             :clj #(-> (clojure.java.io/resource %)
                       (str)
                       (clojure.string/replace #\"^jar:file\" \"zipfile\")
                       (clojure.string/replace #\"\\.jar!/\" \".jar::\"))))
        ",
        name)
}

pub fn eval(code: &str, ns: &str, lang: &Lang) -> String {
    match lang {
        Lang::Clojure => format!(
            "
            (try
              (ns {})
              (clojure.core/eval (clojure.core/read-string {{:read-cond :allow}} \"(do {})\"))
              (catch Throwable e
                (binding [*out* *err*]
                  (print (-> e Throwable->map clojure.main/ex-triage clojure.main/ex-str))
                  (flush))))
            ",
            ns,
            util::escape_quotes(code),
        ),
        Lang::ClojureScript => format!("(in-ns '{}) {}", ns, code),
    }
}
