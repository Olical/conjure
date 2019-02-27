(ns conjure.code
  "Generation and manipulation of all Clojure and ClojureScript."
  (:require [zprint.core :as zp]))

(defn pretty-print [s]
  (zp/zprint-str (str s)
                 {:parse-string-all? true
                  :parse {:interpose "\n\n"}}))

