(ns my.cool-ns
  (:require [clojure.edn :as edn]))

(defn run []
  (prn "This is Clojure!"))

(comment
  (run))

#"(this is a regex)"

(def entry-re #"[([\d\-\s:]+)] (.*)")

(edn/read-string "10")
