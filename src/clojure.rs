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
        (if-let [loc (if-let [sym (and (not (find-ns '{})) (resolve '{}))]
                       (mapv (meta sym) [:file :line :column])
                       (when-let [syms #?(:cljs (ns-interns '{})
                                          :clj (some-> (find-ns '{}) ns-interns))]
                         (when-let [file (:file (meta (-> syms first val)))]
                           [file 1 1])))]
          (-> loc
              (update
                0
                #?(:cljs identity
                   :clj #(-> (clojure.java.io/resource %)
                             (str)
                             (clojure.string/replace #\"^jar:file\" \"zipfile\")
                             (clojure.string/replace #\"\\.jar!/\" \".jar::\"))))
              (update 2 dec))
          :unknown)
        ",
        name, name, name, name
    )
}

pub fn complete(name: &str) -> String {
    format!(
        "(str \\[ (clojure.string/join \", \" (map #(str \\' % \\') [\"henlo\" \"fren\"])) \\])"
    )
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
