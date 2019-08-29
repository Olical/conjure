;; Some example code to test Conjure with.

(ns test.example
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

(comment
  (:doc
    #?(:clj (do
              (require 'conjure-deps.orchard.v0v5v0-beta12.orchard.meta)
              (conjure-deps.orchard.v0v5v0-beta12.orchard.meta/var-meta #'clojure.core/+))
       :cljs (do
               (require 'conjure-deps.orchard.v0v5v0-beta12.orchard.cljs.analysis)
               (conjure-deps.orchard.v0v5v0-beta12.orchard.cljs.analysis/var-meta #'clojure.core/+)))))
