(ns dev.sandbox
  "This is a namespace."
  (:require [clojure.test :as t]
            #?(:clj [clojure.tools.logging :as log])))

#_(require 'dev.foo) ; cljs
#_(require 'dev.bar) ; clj

#?(:clj (log/info "Logging!"))

:some-namespaced/keyword

(defn add
  "Hello, World!
  This is a function."
  [a b]
  (+ a b))

(add 1 2)

(rand-int 10)

(def some-state (atom 20))
@some-state

^{:some-meta true}
{:a 1} ;; <-- no result when I set cursor here and call :ConjureEvalCurrentForm

^:some-meta {:a 10}

{:a 1} ;; <-- works fine I set cursor here and call :ConjureEvalCurrentForm

;; note that :ConjureEvalRootForm works fine

#{:a :b :c}
#?(:clj :hi-clojure :cljs :hi-cljs)
#(+ 1 %)
'(+ 10 20)
`(+ 10 20)
#_(+ 10 20)

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

{:foo {:bar {:baz {:quux [1 2 3]}}}}
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

(let [some-local-thing 10
      some-other-local-thing 20]
  some-local-thing)

(comment
  (set! *print-length* 5)

  (throw (Error. "ohno"))
  (do (print "start ")
      (Thread/sleep 5000)
      (println "FOO")
      :done)
  (+ 10 20)

  (future
    (do (print "start ")
        (flush)
        (Thread/sleep 500)
        (println "BAR")))

  ;; Evaluating a string containing a null throws in Conjure.
  ;; https://github.com/Olical/conjure/issues/212
  (do "\0")

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

  ;; Shadow.
  ; :ConjureShadowSelect app
  (shadow.cljs.devtools.api/nrepl-select :app)
  (shadow.cljs.devtools.api/node-repl)

  (enable-console-print!)
  (throw (js/Error. "ohno"))
  :cljs/quit)

(defrecord Person [fname lname address])
(defrecord Address [street city state zip])

(def stu (Person. "Stu" "Halloway"
           (Address. "200 N Mangum"
                      "Durham"
                      "NC"
                      27701)))

(comment
  (clojure.pprint/pprint stu)
  (pr stu))
