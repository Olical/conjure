(ns conjure.code-test
  (:require [clojure.string :as str]
            [clojure.test :as t]
            [conjure.code :as code]))

(t/deftest eval-tmpl
  ;; https://github.com/Olical/conjure/issues/54
  (letfn [(eval-tmpl [lang code]
            (code/render :eval {:conn {:lang lang}
                                :code code}))]
    (t/is (str/ends-with?
            (eval-tmpl :cljs "(inc a) (inc b)")
            "(do (inc a) (inc b)\n)"))
    (t/is (str/ends-with?
            (eval-tmpl :cljs ":foo :bar")
            "(do :foo :bar\n)"))
    (t/is (str/ends-with?
            (eval-tmpl :cljs "(ns xyz)")
            "(ns xyz)\n"))
    (t/is (str/ends-with?
            (eval-tmpl :cljs "(oh no")
            "(do (oh no\n)"))))
