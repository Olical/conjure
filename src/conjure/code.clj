(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [clojure.string :as str]
            [zprint.core :as zp]
            [taoensso.timbre :as log]))

(defn zprint [src]
  (let [code (if (string? src)
               src
               (pr-str src))]
    (try
      (zp/zprint-str code {:parse-string-all? true})
      (catch Exception e
        (log/error "Error while zprinting" e)
        (if (string? code)
          code
          (pr-str code))))))

(defn sample [code]
  (let [flat (str/replace code #"\s+" " ")]
    (if (> (count flat) 30)
      (str (subs flat 0 30) "…")
      flat)))

(defn doc-str [name]
  (str "
       (require 'clojure.repl)
       (with-out-str
         (clojure.repl/doc " name "))
       "))
