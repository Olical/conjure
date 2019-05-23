(ns conjure.code-test
  (:require [clojure.test :as t]
            [conjure.code :as code]
            [conjure.result :as result]))

(t/deftest sample
  (t/is (= (code/sample "this is some code") "this is some code"))
  (t/is (= (code/sample "this is some long code and it exceeds the character limit")
           "this is some long code and it exceeds the characte…")))

(t/deftest parse-code
  (t/is (= (code/parse-code "{:foo :bar}") {:foo :bar})))

(t/deftest parse-ns
  (t/is (= (code/parse-ns "lol nope") [:ok nil]))
  (t/is (= (code/parse-ns "(+ 10 10)") [:ok nil]))
  (t/is (= (code/parse-ns "(ns some.ns-woo)") [:ok 'some.ns-woo]))
  (t/is (= (code/parse-ns "(ns some.ns-woo \"some docs\")") [:ok 'some.ns-woo]))
  (t/is (= (code/parse-ns "(ns ^{:doc \"foo\"} best.ns)") [:ok 'best.ns]))
  (t/is (result/error? (code/parse-ns "(bad"))))
