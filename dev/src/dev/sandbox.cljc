(ns dev.sandbox
  "This is a namespace."
  (:require [clojure.test :as t]))

(defn add
  "Hello, World!
  This is a function."
  [a b]
  (+ a b))

; :ConjureConfig clojure.nrepl/refresh.after "dev.sandbox/after-refresh"
(defn after-refresh []
  (println "All done!"))

(range 30)

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

  ;; Piggieback.
  ; :ConjureEval (require 'cljs.repl.node)
  ; :ConjurePiggieback (cljs.repl.node/repl-env)
  (require '[cider.piggieback :as piggieback]
           '[cljs.repl.node :as node-repl])
  (piggieback/cljs-repl (node-repl/repl-env))

  ;; Shadow.
  ; :ConjureShadowSelect app
  (shadow.cljs.devtools.api/nrepl-select :app)

  (enable-console-print!)
  (throw (js/Error. "ohno"))
  :cljs/quit)
