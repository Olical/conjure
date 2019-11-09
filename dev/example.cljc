;; Some example code to test Conjure with.

(ns dev.example
  (:require [clojure.test :as t]))

(defn henlo [name]
  (println (str "Henlo, " name "!"))
  :done)

(defn get-env []
  #?(:clj :Clojure, :cljs :ClojureScript))

(+ 10 20)

(comment
  (this-will-error))

(t/deftest something-simple
  (t/testing "hmm"
    (t/is (= 10 10))))

[(henlo "Ollie") (get-env)]
