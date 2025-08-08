(local {: autoload } (require :conjure.nfnl.module))
(local {: describe : it } (require :plenary.busted))
(local assert (autoload :luassert.assert))
(local a (autoload :conjure.nfnl.core))
(local scheme (require :conjure.client.scheme.stdio))
(local config (autoload :conjure.config))
(local mock-stdio (require :conjure-spec.client.scheme.mock-stdio))
(local mock-tsc (require :conjure-spec.mock-tree-sitter-completions))
(local mock-log (require :conjure-spec.mock-log))

(tset package.loaded "conjure.tree-sitter-completions" mock-tsc)
(tset package.loaded "conjure.log" mock-log)

(describe "conjure.client.scheme.stdio"
  (fn []
    (tset package.loaded "conjure.remote.stdio" mock-stdio)

    (it "eval-str sends code to repl when parses"
      (fn [] 
        (let [expected-code "(some code)"
              send-calls [] 
              mock-send (fn [val] (table.insert send-calls val))]
          (tset scheme :valid-str? (fn [_] true))
          (mock-stdio.set-mock-send mock-send) 

          (scheme.start)
          (scheme.eval-str {:code expected-code})
          (scheme.stop)

          (assert.same [(.. expected-code "\n")] send-calls))))

    (it "eval-str does not send code to repl when valid-str? returns false"
      (fn [] 
        (let [send-calls [] 
              mock-send (fn [val] (table.insert send-calls val))]
          (tset scheme :valid-str? (fn [_] false))
          (mock-stdio.set-mock-send mock-send) 

          (scheme.start)
          (scheme.eval-str {:code "(some invalid form"})
          (scheme.stop)

          (assert.same [] send-calls)))))
    
    (describe "completions"
      (fn []
        (it "returns delay for prefix dela when no treesitter completions"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions [])

              (scheme.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same ["delay"] (. completion-results 1)))))

        (it "returns delta for prefix delt when treesitter completion delta and other"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delta" "other"])

              (scheme.completions 
                {:prefix "delt"
                 :cb completion-callback})

              (assert.same ["delta"] (. completion-results 1)))))

        (it "returns delay-more and delay for prefix dela when treesitter completion delay-more"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delay-more"])

              (scheme.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same ["delay-more" "delay"] (. completion-results 1)))))

        (it "returns delta as first result for prefix nil when treesitter completion delta"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delta"])

              (scheme.completions 
                {:prefix nil
                 :cb completion-callback})

              (assert.same "delta" (a.get-in completion-results [1 1])))))))

    (describe "config"
      (fn []
        (it "returns empty list for completions when completions disabled"
          (fn []
            (config.merge {:client {:scheme {:stdio
                            {:enable_completions false}}}}
                          {:overwrite? true})

            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delay"])

              (scheme.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same [] (. completion-results 1)))))

        (it "returns delay delay-more for completions when completions enabled and tree sitter completion delay-more"
            (fn []
              (config.merge {:client {:scheme {:stdio
                               {:enable_completions true}}}}
                            {:overwrite? true})
              (let [completion-results []
                    completion-callback 
                    (fn [res] (table.insert completion-results res))] 
                (mock-tsc.set-mock-completions ["delay-more"])

                (scheme.completions 
                  {:prefix "dela"
                   :cb completion-callback})

                (assert.same ["delay-more" "delay"] (. completion-results 1))))))))
