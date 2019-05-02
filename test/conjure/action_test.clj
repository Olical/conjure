(ns conjure.action-test
  (:require [clojure.test :as t]
            [conjure.action :as action]
            [conjure.ui :as ui]))

;; Maybe this makes more sense as an integration test.

(def appends! (atom nil))

(t/use-fixtures
  :each
  (fn [f]
    (try
      (binding [ui/append (fn [v] (swap! appends! conj v))]
        (f))
      (finally
        (reset! appends! nil)))))

#_(t/deftest eval*
    (action/eval* {:code "(+ 10 10)"})
    (t/is (= @appends! [])))
