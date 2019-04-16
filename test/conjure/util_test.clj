(ns conjure.util-test
  (:require [clojure.test :as t]
            [conjure.util :as util]))

(t/deftest join-words
  (t/is (= (util/join-words nil) ""))
  (t/is (= (util/join-words []) ""))
  (t/is (= (util/join-words ["foo" "bar"]) "foo bar")))

(t/deftest escape-quotes
  (t/is (= (util/escape-quotes "\"\"") "\\\"\\\"")))

(t/deftest count-str
  (t/is (= (util/count-str [] "number") "0 numbers"))
  (t/is (= (util/count-str [1] "number") "1 number"))
  (t/is (= (util/count-str [1 2] "number") "2 numbers")))

(t/deftest free-port
  (t/is (number? (util/free-port))))
