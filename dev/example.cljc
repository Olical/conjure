;; Some example code to test Conjure with.

(ns test.example
  (:require [clojure.test :as t]))

(defn henlo [name]
  (println (str "Henlo, " name "!"))
  :done)

(defn get-env []
  #?(:clj :Clojure, :cljs :ClojureScript))

(+ 10 20)

[(henlo "Ollie") (get-env)]

(comment
  (this-will-error))

(t/deftest something-simple
  (t/testing "hmm"
    (t/is (= 10 10))))

(defn positive-numbers
  ([] (positive-numbers 1))
  ([n]
   (prn "x")
   (lazy-seq (cons n (positive-numbers (inc n))))))

(take 10 (positive-numbers))
