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

(t/deftest error?
  (t/is (result/error? [:error :ohno]))
  (t/is (not (result/error? [:ok :yay]))))

(t/deftest ok?
  (t/is (result/ok? [:ok :yay]))
  (t/is (not (result/ok? [:error :ohno]))))

(t/deftest error
  (t/is (= (result/error [:error :ohno]) :ohno))
  (t/is (= (result/error [:ok :yay]) nil)))

(t/deftest ok
  (t/is (= (result/ok [:ok :yay]) :yay))
  (t/is (= (result/ok [:error :ohno]) nil)))
