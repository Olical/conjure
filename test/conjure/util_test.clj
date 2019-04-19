(ns conjure.util-test
  (:require [clojure.test :as t]
            [conjure.util :as util]))

(t/deftest join-words
  (t/is (= (util/join-words nil) ""))
  (t/is (= (util/join-words []) ""))
  (t/is (= (util/join-words ["foo" "bar"]) "foo bar")))

(t/deftest split-lines
  (t/is (= (util/split-lines "") [""]))
  (t/is (= (util/split-lines "foo\nbar") ["foo" "bar"])))

(t/deftest join-lines
  (t/is (= (util/join-lines []) ""))
  (t/is (= (util/join-lines ["foo" "bar"]) "foo\nbar")))

(t/deftest splice
  (t/is (= (util/splice "" 0 0 "") ""))
  
  (t/is (= (util/splice "" 0 0 "foo") "foo"))
  (t/is (= (util/splice "Hello, World!" 7 12 "Conjure") "Hello, Conjure!"))

  (t/testing "exceeding boundaries"
    (t/is (= (util/splice "" 0 1 "") ""))
    (t/is (= (util/splice "" -1 0 "") ""))
    (t/is (= (util/splice "Hello, World!" 7 20 "Conjure?") "Hello, Conjure?"))))

(t/deftest escape-quotes
  (t/is (= (util/escape-quotes "\"\"") "\\\"\\\"")))

(t/deftest pprint
  (t/is (util/pprint {:foo :bar}) "{:foo :bar}"))

(t/deftest count-str
  (t/is (= (util/count-str [] "number") "0 numbers"))
  (t/is (= (util/count-str [1] "number") "1 number"))
  (t/is (= (util/count-str [1 2] "number") "2 numbers")))

(t/deftest free-port
  (t/is (number? (util/free-port))))

(t/deftest env
  (binding [util/get-env-fn {"CONJURE_FOO_BAR" :baz}]
    (t/is (= (util/env :foo-bar) :baz))))

(t/deftest regexp?
  (t/is (util/regexp? #"foo"))
  (t/is (not (util/regexp? "foo"))))
