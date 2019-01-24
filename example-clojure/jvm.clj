(ns my.cool-ns
  (:require [clojure.edn :as edn]
            [clojure.test :as t]))

(defn run []
  (prn "This is Clojure!"))

::foo

(comment
  (run)
  (nope))

#"(this is a regex)"

(def entry-re #"[([\d\-\s:]+)] (.*)")

(edn/read-string "10")

(t/deftest foo
  (t/testing "some-thing"
    (t/is (= 10 10))))
