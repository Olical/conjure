(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local stub (require :luassert.stub))
(local config (require :conjure.config))

;; stub configuration fn that returns values for:
;; conjure#client#clojure#nrepl#test#current_form_names
;; conjure#client#clojure#nrepl#test#runner
(local original-get-in-fn config.get-in-fn)
(local get-in-fn-stub (stub config "get-in-fn"))
(get-in-fn-stub.invokes original-get-in-fn)
(local action-cfg (get-in-fn-stub.on_call_with [:client :clojure :nrepl]))
(var test-current-form-names [:test-symbol-x :test-symbol-y])
(var test-runner "some-custom-runner")
(action-cfg.returns
  (fn [args]
    (case args
      ["test" "current_form_names"] test-current-form-names
      ["test" "runner"]             test-runner
      _                             (original-get-in-fn args))))

(local action (require :conjure.client.clojure.nrepl.action))

(describe "client.clojure.nrepl.action"
  (fn []
    (describe "extract-test-name-from-form"
      (fn []
        (it "deftest form with missing name"
          (fn []
            (assert.are.equals nil (action.extract-test-name-from-form ""))))
        (it "normal deftest form"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-x foo (+ 10 20))"))))
        (it "normal deftest form - using another symbol"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-y foo (+ 10 20))"))))
        (it "deftest form with extra spaces"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(   test-symbol-x  foo  (+ 10 20))"))))
        (it "deftest form with metadata"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-x ^:kaocha/skip foo :xyz)"))))))

    (describe "extract-test-runner-specific-name-from-form"
        (fn []
          (set action.test-runners {:some-custom-runner {:current-form-names [:test-symbol-a :test-symbol-b]}})
          (it "uses test-runner-specific deftest form"
            (fn []
              (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-a foo (+ 10 20))"))))
          (it "also uses test-runner-specific deftest form with multiple symbols"
            (fn []
              (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-b foo (+ 10 20))"))))
          (it "also uses test form from conjure config"
            (fn []
              (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-x foo (+ 10 20))"))))
          (it "also uses other deftest form from conjure config"
            (fn []
              (assert.are.equals "foo" (action.extract-test-name-from-form "(test-symbol-y foo (+ 10 20))"))))))

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
