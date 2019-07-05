(ns conjure.code-test
  (:require [clojure.test :as t]
            [conjure.code :as code]))

(t/deftest parse-code
  (t/is (= (code/parse-code "{:foo :bar}") {:foo :bar}))
  (t/is (= (code/parse-code "(ohno(})") nil)))

(t/deftest parse-ns
  (t/is (= (code/parse-ns "lol nope") nil))
  (t/is (= (code/parse-ns "(+ 10 10)") nil))
  (t/is (= (code/parse-ns "(ns some.ns-woo)") 'some.ns-woo))
  (t/is (= (code/parse-ns "(ns some.ns-woo \"some docs\")") 'some.ns-woo))
  (t/is (= (code/parse-ns "(ns ^{:doc \"foo\"} best.ns)") 'best.ns))
  (t/is (= (code/parse-ns "(bad") ::code/error)))
