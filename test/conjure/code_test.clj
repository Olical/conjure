(ns conjure.code-test
  (:require [clojure.test :as t]
            [conjure.code :as code]))

(t/deftest sample
  (t/is (= (code/sample "this is some code") "this is some code"))
  (t/is (= (code/sample "this is some long code and it exceeds the character limit")
           "this is some long code and it exceeds the …")))

(t/deftest parse-ns
  (t/is (= (code/parse-ns "lol nope") nil))
  (t/is (= (code/parse-ns "(+ 10 10)") nil))
  (t/is (= (code/parse-ns "(ns some.ns-woo)") 'some.ns-woo))
  (t/is (= (code/parse-ns "(ns some.ns-woo \"some docs\")") 'some.ns-woo))
  (t/is (= (code/parse-ns "(ns ^{:doc \"foo\"} best.ns)") 'best.ns)))
