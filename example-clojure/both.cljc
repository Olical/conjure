(ns hybrid.stuff
  (:require [#?(:clj clojure.test, :cljs cljs.test) :as t]))

(defn run []
  #?(:clj (prn "This is Clojure!")
     :cljs (prn "This is ClojureScript!")))

(comment
  (run)
  (throw (#?(:clj Error., :cljs js/Error.) "ohno")))

(t/deftest foo
  (t/testing "some-thing"
    (t/is (= 10 10))))
