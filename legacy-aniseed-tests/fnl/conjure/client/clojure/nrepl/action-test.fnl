(module conjure.client.clojure.nrepl.action-test
  {require {action conjure.client.clojure.nrepl.action}})

(deftest extract-test-name-from-form
  (t.= nil (action.extract-test-name-from-form ""))
  (t.= "foo" (action.extract-test-name-from-form "(deftest foo (+ 10 20))"))
  (t.= "foo" (action.extract-test-name-from-form "(   deftest  foo  (+ 10 20))"))
  (t.= "foo" (action.extract-test-name-from-form "(deftest ^:kaocha/skip foo :xyz)")))
