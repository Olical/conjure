(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local action (require :conjure.client.clojure.nrepl.action))

(describe "client.clojure.nrepl.action"
  (fn []
    (describe "extract-test-name-from-form"
      (fn []
        ;; Simulate config items with [:test :current_form_names] for clojure client.
        (set vim.g.conjure#client#clojure#nrepl#test#current_form_names [:deftest])

        (it "deftest form with missing name"
          (fn []
            (assert.are.equals nil (action.extract-test-name-from-form ""))))
        (it "normal deftest form"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest foo (+ 10 20))"))))
        (it "deftest form with extra spaces"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(   deftest  foo  (+ 10 20))"))))
        (it "deftest form with metadata"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest ^:kaocha/skip foo :xyz)"))))))))
