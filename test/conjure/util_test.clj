(ns conjure.util-test
  (:require [clojure.test :as t]
            [conjure.util :as util]))

(t/deftest join-words
  (t/is (= (util/join-words []) ""))
  (t/is (= (util/join-words ["foo" "bar"]) "foo bar")))
