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

    (describe "clojure->vim-completion"
      (fn []
        (it "uses the full nREPL type as the kind"
          (fn []
            (each [_ t (ipairs [:function :macro :special-form :var :local
                                :namespace :class :keyword :resource :method
                                :static-method :field :static-field :data-reader])]
              (assert.are.equals
                t
                (. (action.clojure->vim-completion {:candidate "x" :type t}) :kind)))))

        (it "has no kind when the type is missing or empty"
          (fn []
            (assert.is_nil (. (action.clojure->vim-completion {:candidate "x"}) :kind))
            (assert.is_nil (. (action.clojure->vim-completion {:candidate "x" :type ""}) :kind))))

        (it "builds the menu and info from the other fields"
          (fn []
            (assert.same
              {:word "map"
               :menu "clojure.core ([f coll]) ([f c1 c2])"
               :info "Returns a lazy sequence."
               :kind "function"}
              (action.clojure->vim-completion
                {:candidate "map"
                 :type "function"
                 :ns "clojure.core"
                 :doc "Returns a lazy sequence."
                 :arglists ["([f coll])" "([f c1 c2])"]}))))))))
