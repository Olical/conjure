(ns conjure.code-test
  (:require [clojure.string :as str]
            [clojure.test :as t]
            [conjure.code :as code]))

(t/deftest eval-str
  ;; https://github.com/Olical/conjure/issues/54
  (letfn [(eval-str [lang code]
            (code/eval-str {} {:conn {:lang lang}
                               :code code}))]
    (t/is (str/ends-with?
            (eval-str :cljs "(inc a) (inc b)")
            "(do (inc a) (inc b)\n)"))
    (t/is (str/ends-with?
            (eval-str :cljs ":foo :bar")
            "(do :foo :bar\n)"))
    (t/is (str/ends-with?
            (eval-str :cljs "(ns xyz)")
            "(ns xyz)\n"))
    (t/is (str/ends-with?
            (eval-str :cljs "(oh no")
            "(do (oh no\n)"))))
