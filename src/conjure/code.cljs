(ns conjure.code
  "Generation and manipulation of all Clojure and ClojureScript."
  (:require [clojure.string :as str]
            [zprint.core :as zp]
            [conjure.display :as display]))

;; This is kind of a workaround since zprint complains once (and only once) if
;; you ask it to format a nil with: find-ns-obj not supported for target node.
;; This set can be expanded if required but I highly doubt it'll ever need to.
(def already-pretty #{"nil"})

(defn pretty-print [s]
  (if (contains? already-pretty s)
    s
    (try
      (zp/zprint-str (str s)
                     {:parse-string-all? true
                      :parse {:interpose "\n\n"}})
      (catch :default e
        (display/error! (str "Error while pretty-printing " e "\n" s))
        s))))

(defn sample [s]
  (let [flat (str/replace s #"\n" "")]
    (if (> (count flat) 30)
      (str (subs flat 0 30) "...")
      flat)))
