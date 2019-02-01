(ns some.js
  (:require [clojure.set :as set]))

(defn run []
  (prn "This is ClojureScript!"))

(print "hopefully this prints despite no new line")

(comment
  (run)
  (nope))

(set/difference #{1 2 3 4} #{3 4 5 6})
