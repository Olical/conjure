(ns conjure.code
  "Generation and manipulation of all Clojure and ClojureScript."
  (:require [zprint.core :as zp]
            [conjure.display :as display]))

(defn pretty-print [s]
  (try
    (zp/zprint-str (str s)
                   {:parse-string-all? true
                    :parse {:interpose "\n\n"}})
    (catch :default e
      (display/error! nil e)
      s)))

