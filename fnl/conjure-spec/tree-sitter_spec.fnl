(local {: describe : it : before_each : after_each } (require :plenary.busted))
(local ts (require :conjure.tree-sitter))

(var saved-get-string-parser nil)

(describe "conjure.tree-sitter"
  (fn []
    (describe "valid-str?" 
      (fn []
        (before_each
          (fn []
            (set saved-get-string-parser vim.treesitter.get_string_parser)))
        (after_each
          (fn []
            (tset vim.treesitter :get_string_parser saved-get-string-parser)))

        (it "returns false when root node has error"
            (fn []
              (let [mock-root-node {:has_error (fn [] true)}
                    mock-root-tree {:root (fn [] mock-root-node)}]
                (tset vim.treesitter :get_string_parser 
                      (fn [] {:parse (fn [])
                              :trees (fn [] [mock-root-tree])}))

                (assert.is_false (ts.valid-str? :some-lang "(some bad code")))))

        (it "returns falsy when nil parse trees is returned"
            (fn []
              (tset vim.treesitter :get_string_parser 
                    (fn [] {:parse (fn [])
                            :trees (fn [] nil)}))

              (assert.is_falsy (ts.valid-str? :some-lang "code"))))

        (it "returns falsy when empty parse trees array is returned"
            (fn []
              (tset vim.treesitter :get_string_parser 
                    (fn [] {:parse (fn [])
                            :trees (fn [] [])}))

              (assert.is_falsy (ts.valid-str? :some-lang "code"))))

        (it "returns falsy when returned root node nil"
            (fn []
              (let [mock-root-tree {:root (fn [] nil)}]
                (tset vim.treesitter :get_string_parser 
                      (fn [] {:parse (fn [])
                              :trees (fn [] [mock-root-tree])}))

                (assert.is_falsy (ts.valid-str? :some-lang "code")))))

        (it "returns true when root node does not have errors"
            (fn []
              (let [mock-root-node {:has_error (fn [] false)}
                    mock-root-tree {:root (fn [] mock-root-node)}]
                (tset vim.treesitter :get_string_parser 
                      (fn [] {:parse (fn [])
                              :trees (fn [] [mock-root-tree])}))

                (assert.is_true (ts.valid-str? :some-lang "(some code)")))))))))
