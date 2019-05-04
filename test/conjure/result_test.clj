(ns conjure.result-test
  (:require [clojure.test :as t]
            [conjure.result :as result]))

(t/deftest kind
  (t/is (= (result/kind 10) nil))
  (t/is (= (result/kind [1 2 3]) nil))
  (t/is (= (result/kind ["foo" :bar]) nil))
  (t/is (= (result/kind [:foo :bar]) :foo)))

(t/deftest value
  (t/is (= (result/value 10) nil))
  (t/is (= (result/value [1 2 3]) nil))
  (t/is (= (result/value ["foo" :bar]) nil))
  (t/is (= (result/value [:foo :bar]) :bar)))
