(ns conjure.code
  "Generation and manipulation of all Clojure and ClojureScript."
  (:require [clojure.string :as str]
            [zprint.core :as zp]
            [conjure.display :as display]))

(defn pretty-print [s]
  (try
    (zp/zprint-str (str s)
                   {:parse-string-all? true
                    :parse {:interpose "\n\n"}})
    (catch :default e
      (display/log! {:conn {:tag :conjure}, :value {:tag :err, :val (str e)}})
      s)))

(defn sample [s]
  (let [flat (str/replace s #"\n" "")]
    (if (> (count flat) 30)
      (str (subs flat 0 30) "...")
      flat)))
