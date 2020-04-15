(ns dev.foo
  (:require [clojure.test :as t]))

(defn add [a b]
  (+ a b))

(meta #'add)
(time (add 10 20))
(println "foo" #?(:clj :clojure! :cljs :clojurescript!))

*1 *2 *3 *e

(t/deftest test-a
  (t/testing "foo"
    (t/is (= 10 10))))

(t/deftest test-b
  (t/testing "bar"
    (t/is (= 10 10))))

(comment
  (throw (Error. "ohno"))
  (do (Thread/sleep 5000)
      (println "FOO"))
  (do (Thread/sleep 5000)
      (println "BAR"))

  (require '[cider.piggieback :as piggieback]
           '[cljs.repl.node :as node-repl])
  (piggieback/cljs-repl (node-repl/repl-env))
  (enable-console-print!)
  (throw (js/Error. "ohno"))
  :cljs/quit)
