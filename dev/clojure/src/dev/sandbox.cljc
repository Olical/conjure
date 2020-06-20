(ns dev.sandbox
  "This is a namespace."
  (:require [clojure.test :as t]
            #?(:clj [clojure.tools.logging :as log])))

#_(require 'dev.foo) ; cljs
#_(require 'dev.bar) ; clj

#?(:clj (log/info "Logging!"))

(defn add
  "Hello, World!
  This is a function."
  [a b]
  (+ a b))

(println "\033[0;31mHello, World!\033[0m")

{:xyz
 [(add 10 20)
  (add 1 2)]}

(println (apply str (take 2000 (repeat \x))))

(do
  (print (apply str (take 500 (repeat \x))))
  (println (apply str (take 300 (repeat \x)))))

(do
  (print "foo ")
  (print "bar ")
  (println "baz")
  (print "new line")
  (print " same!\n")
  (println "     some indentation")
  (println "last on own"))

(comment
  (+ 5 1) (+ 10 20) :foo
  (+ 1 2))

; :let g:conjure#client#clojure#nrepl#refresh#after = "dev.sandbox/after-refresh"
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
  (do (print "start ")
      (Thread/sleep 5000)
      (println "FOO"))
  (future
    (do (print "start ")
        (flush)
        (Thread/sleep 500)
        (println "BAR")))

  (tap> :foo)

  (run!
    (fn [_]
      (print "=")
      (flush)
      (Thread/sleep 50))
    (range 50))

  (read)
  (read-line)

  ;; Piggieback.
  ; :ConjureEval (require 'cljs.repl.node)
  ; :ConjurePiggieback (cljs.repl.node/repl-env)
  (require '[cider.piggieback :as piggieback]
           '[cljs.repl.node :as node-repl])
  (piggieback/cljs-repl (node-repl/repl-env))

  (clojure.string/split-lines (slurp "/home/oliver/Downloads/cities.csv"))

  ;; Shadow.
  ; :ConjureShadowSelect app
  (shadow.cljs.devtools.api/nrepl-select :app)
  (shadow.cljs.devtools.api/node-repl)

  (enable-console-print!)
  (throw (js/Error. "ohno"))
  :cljs/quit)
