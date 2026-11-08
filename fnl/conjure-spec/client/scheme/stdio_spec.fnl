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

    (describe "format-msg"
      (fn []
        (it "preserves Chez output ending in a space and number"
          (fn []
            (assert.same ["; (out) number after, with space: 1"]
              (scheme.format-msg {:out "number after, with space: 1"}))))

        (it "preserves a final numeric line in batched output"
          (fn []
            (assert.same ["; (out) first line" "; (out) 42"]
              (scheme.format-msg
                (scheme.unbatch [{:out "first line\n"} {:out "42"}])))))

        (it "preserves numeric MIT Scheme values"
          (fn []
            (assert.same ["42"]
              (scheme.format-msg {:out ";Value: 42"}))))

        (it "treats displayed text that looks like a value as output"
          (fn []
            (assert.same ["; (out) ;Value: 3" "; (out) ;Unspecified return value"]
              (scheme.format-msg
                (scheme.unbatch [{:out "\n;Value: 3\n;Unspecified return value\n\n1 ]=> "}])))))

        (it "only treats a prompt at the end of the output as the prompt"
          (fn []
            (let [prompt (config.get-in [:client :scheme :stdio :prompt_pattern])]
              (assert.is_nil (string.find "shown 2 ]=> here\n" prompt))
              (assert.is_truthy (string.find ";Value: 42\n\n1 ]=> " prompt)))))))

    (it "preserves Chez numeric output with value prefixes disabled"
      (fn []
        (let [key "conjure#client#scheme#stdio#value_prefix_pattern"
              previous (. vim.g key)]
          (tset vim.g key false)
          (let [actual (scheme.format-msg {:out "number: 1\n42\n"})]
            (tset vim.g key previous)
            (assert.same ["number: 1" "42"] actual)))))

    (describe "prompt cleanup"
      (fn []
        (it "removes normal and error prompt levels after joining split reads"
          (fn []
            (each [_ prompt (ipairs ["1 ]=> " "12 error> "])]
              (each [_ split (ipairs [0 1 2 3])]
                (let [msgs [{:out (.. "number: 42\n" (string.sub prompt 1 split))}
                            {:out (string.sub prompt (+ split 1))}]
                      lines (scheme.format-msg (scheme.unbatch msgs))]
                  (assert.same ["; (out) number: 42"] lines))))))))

    (it "keeps the MIT value as the final result without a prompt blank line"
      (fn []
        (assert.same ["42"]
          (scheme.format-msg
            (scheme.unbatch [{:out ";Value: 42\n\n1 "} {:out "]=> "}])))))

    (it "keeps custom prompt stripping in the transport"
      (fn []
        (let [key "conjure#client#scheme#stdio#prompt_pattern"
              previous (. vim.g key)]
          (tset vim.g key "^> ")
          (scheme.start)
          (let [opts (mock-stdio.get-last-opts)
                actual (scheme.format-msg {:out "number: 42"})]
            (scheme.stop)
            (tset vim.g key previous)
            (assert.same "^> " opts.prompt-pattern)
            (assert.is_false opts.preserve-prompt?)
            (assert.same ["; (out) number: 42"] actual)))))

    (it "preserves the reported output with the original Chez quick-start settings"
      (fn []
        (let [command-key "conjure#client#scheme#stdio#command"
              prompt-key "conjure#client#scheme#stdio#prompt_pattern"
              previous-command (. vim.g command-key)
              previous-prompt (. vim.g prompt-key)]
          (tset vim.g command-key "petite")
          (tset vim.g prompt-key "> $?")
          (scheme.start)
          (let [opts (mock-stdio.get-last-opts)
                output "number after, without space:1\nnumber after, with space: 1\n> "
                stripped (string.gsub output opts.prompt-pattern "")
                actual (scheme.format-msg {:out stripped})]
            (scheme.stop)
            (tset vim.g command-key previous-command)
            (tset vim.g prompt-key previous-prompt)
            (assert.same "petite" opts.cmd)
            (assert.same "> $?" opts.prompt-pattern)
            (assert.is_false opts.preserve-prompt?)
            (assert.same ["; (out) number after, without space:1"
                          "; (out) number after, with space: 1"
                          "; (out) "] actual)))))

    (it "preserves numbers with nested Chez prompts and value prefixes disabled"
      (fn []
        (let [command-key "conjure#client#scheme#stdio#command"
              prompt-key "conjure#client#scheme#stdio#prompt_pattern"
              value-key "conjure#client#scheme#stdio#value_prefix_pattern"
              previous-command (. vim.g command-key)
              previous-prompt (. vim.g prompt-key)
              previous-value (. vim.g value-key)]
          (tset vim.g command-key "petite")
          (tset vim.g prompt-key ">+ ")
          (tset vim.g value-key false)
          (scheme.start)
          (let [opts (mock-stdio.get-last-opts)
                results (a.map
                          (fn [prompt]
                            (scheme.format-msg
                              {:out (string.gsub
                                      (.. "number after, without space:1\nnumber after, with space: 1\n" prompt)
                                      opts.prompt-pattern "")}))
                          ["> " ">> " ">>> "])]
            (scheme.stop)
            (tset vim.g command-key previous-command)
            (tset vim.g prompt-key previous-prompt)
            (tset vim.g value-key previous-value)
            (assert.is_false opts.preserve-prompt?)
            (each [_ actual (ipairs results)]
              (assert.same ["number after, without space:1"
                            "number after, with space: 1"] actual))))))

    (it "eval-str sends code to repl when parses"
      (fn [] 
        (let [expected-code "(some code)"
              send-calls [] 
              mock-send (fn [val] (table.insert send-calls val))]
          (tset scheme :valid-str? (fn [_] true))
          (mock-stdio.set-mock-send mock-send) 

          (scheme.start)
          (assert.is_true (. (mock-stdio.get-last-opts) :preserve-prompt?))
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
