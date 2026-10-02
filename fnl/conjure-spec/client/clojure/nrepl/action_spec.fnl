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
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest ^:kaocha/skip foo :xyz)"))))))
    (describe "extract-test-runner-specific-name-from-form"
       (fn []
         ;; action.test-runners is hard-coded at the moment, so we need to use one of the actual test-runners
         ;; and set the fallback default to something else
         (set vim.g.conjure#client#clojure#nrepl#test#current_form_names [:tsetfed])
         (set vim.g.conjure#client#clojure#nrepl#test#runner "clojurescript")

         (it "test-runner-specific deftest form"
           (fn []
             (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest foo (+ 10 20))"))))))
    (describe "extract-test-runner-specific-name-from-form-with-unknown-runner"
           (fn []
             (set vim.g.conjure#client#clojure#nrepl#test#current_form_names [:deftest])
             (set vim.g.conjure#client#clojure#nrepl#test#runner "unknown-runner")

             (it "test-runner-specific-unknown deftest form - uses fallback"
               (fn []
                 (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest foo (+ 10 20))"))))))
    (describe "extract-test-runner-specific-name-from-form-with-no-config"
           (fn []
             (set vim.g.conjure#client#clojure#nrepl#test#current_form_names nil)
             (set vim.g.conjure#client#clojure#nrepl#test#runner "unknown-runner")

             (it "test-runner-specific-unknown deftest form - returns an error"
               (fn []
                 (assert.error.matches #(action.extract-test-name-from-form "(deftest foo (+ 10 20))") "No value for current-form-names in test or runner configuration" 1 true)))))))
