(ns conjure.util-test
  (:require [clojure.test :as t]
            [conjure.util :as util]))

(t/deftest join-words
  (t/is (= (util/join-words nil) ""))
  (t/is (= (util/join-words []) ""))
  (t/is (= (util/join-words ["foo" "bar"]) "foo bar")))

(t/deftest join-lines
  (t/is (= (util/join-lines []) ""))
  (t/is (= (util/join-lines ["foo" "bar"]) "foo\nbar")))

(t/deftest parse-code
  (t/is (= (util/parse-code "{:foo :bar}") {:foo :bar}))
  (t/is (= (util/parse-code "(ohno(})") nil)))

(t/deftest parse-ns
  (t/is (= (util/parse-ns "lol nope") nil))
  (t/is (= (util/parse-ns "(+ 10 10)") nil))
  (t/is (= (util/parse-ns "(ns some.ns-woo)") 'some.ns-woo))
  (t/is (= (util/parse-ns "(ns some.ns-woo \"some docs\")") 'some.ns-woo))
  (t/is (= (util/parse-ns "(ns ^{:doc \"foo\"} best.ns)") 'best.ns))
  (t/is (= (util/parse-ns "(bad") ::util/error)))

(t/deftest splice
  (t/is (= (util/splice "" 0 0 "") ""))
  
  (t/is (= (util/splice "" 0 0 "foo") "foo"))
  (t/is (= (util/splice "Hello, World!" 7 12 "Conjure") "Hello, Conjure!"))

  (t/testing "exceeding boundaries"
    (t/is (= (util/splice "" 0 1 "") ""))
    (t/is (= (util/splice "" -1 0 "") ""))
    (t/is (= (util/splice "Hello, World!" 7 20 "Conjure?") "Hello, Conjure?"))))

(t/deftest sample
  (t/is (= (util/sample "this is some code" 20) "this is some code"))
  (t/is (= (util/sample "this is some long code" 20) "this is some long co…")))

(t/deftest escape-quotes
  (t/is (= (util/escape-quotes "\"\"") "\\\"\\\"")))

(t/deftest pprint
  (t/is (util/pprint "{:foo :bar}") "{:foo :bar}")
  (t/is (util/pprint "oh} no ('") "oh} no ('"))

(t/deftest throwable->str
  (t/is (re-matches #"Execution error \(Error\) at conjure\.util-test/fn \(util_test\.clj:\d+\)\.\nohno\n"
                    (util/throwable->str (Error. "ohno")))))

(t/deftest count-str
  (t/is (= (util/count-str [] "number") "0 numbers"))
  (t/is (= (util/count-str [1] "number") "1 number"))
  (t/is (= (util/count-str [1 2] "number") "2 numbers")))

(t/deftest free-port
  (t/is (number? (util/free-port))))

(t/deftest env
  (binding [util/get-env-fn {"FOO_BAR" :baz}]
    (t/is (= (util/env :foo-bar) :baz))))

(t/deftest regexp?
  (t/is (util/regexp? #"foo"))
  (t/is (not (util/regexp? "foo"))))

(t/deftest snake->kw
  (t/is (= (util/snake->kw "foo_bar") :foo-bar)))

(t/deftest kw->snake
  (t/is (= (util/kw->snake :foo-bar) "foo_bar")))

(t/deftest snake->kw-map
  (t/is (= (util/snake->kw-map {"foo_bar" :baz}) {:foo-bar :baz})))

(t/deftest kw->snake-map
  (t/is (= (util/kw->snake-map {:foo-bar :baz}) {"foo_bar" :baz})))

(t/deftest write
  (t/is (= (str (util/write (java.io.StringWriter.) "foo")) "foo")))

(t/deftest thread
  (t/is (= @(util/thread "adding" (+ 10 10)) 20)))

(t/deftest pretty-error
  (t/is (re-matches #"(?i); Reason\.\.\.
; ohno

(; #\d+ [\w\.\-/_\*!]+ \(\w+ [\w\.\-/_\*]+:\d+\)\n?)+

; Exception #1 java\.lang\.Error @ conjure\.util-test/fn--\d+ \(invokeStatic util_test\.clj:\d+\)
; ohno"
           (util/pretty-error (Throwable->map (Error. "ohno"))))))

(t/deftest safe-subs
  (t/is (= "oba" (util/safe-subs "foobar" 2 5)))
  (t/is (= "obar" (util/safe-subs "foobar" 2 6)))
  (t/is (= "obar" (util/safe-subs "foobar" 2 7)))
  (t/is (= "oob" (util/safe-subs "foobar" 1 4)))
  (t/is (= "foo" (util/safe-subs "foobar" 0 3)))
  (t/is (= "foo" (util/safe-subs "foobar" -1 3)))
  (t/is (= "foobar" (util/safe-subs "foobar" -1))))
