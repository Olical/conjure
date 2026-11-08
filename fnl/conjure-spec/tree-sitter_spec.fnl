(local {: describe : it : before_each : after_each } (require :plenary.busted))
(local {: autoload } (require :conjure.nfnl.module))
(local ts (require :conjure.tree-sitter))
(local config (autoload :conjure.config))

(var saved-get-string-parser nil)
(var saved-get-parser nil)

(describe "conjure.tree-sitter"
  (fn []
    (describe "valid-str?" 
      (fn []
        (before_each
          (fn []
            (set saved-get-string-parser vim.treesitter.get_string_parser)
            (set saved-get-parser vim.treesitter.get_parser)
            (config.assoc-in [:extract :tree_sitter :enabled] true)
            (tset vim.treesitter :get_parser (fn [] {}))))
        (after_each
          (fn []
            (tset vim.treesitter :get_string_parser saved-get-string-parser)
            (tset vim.treesitter :get_parser saved-get-parser)
            (config.assoc-in [:extract :tree_sitter :enabled] true)))

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

                (assert.is_true (ts.valid-str? :some-lang "(some code)")))))

        (it "returns true when treesitter is disabled in config"
            (fn []
                (config.assoc-in [:extract :tree_sitter :enabled] false)
                (assert.is_true (ts.valid-str? :some-lang "(some bad code"))))

        (it "returns true when treesitter is not present"
            (fn []
              (tset vim.treesitter :get_parser nil)
              (assert.is_true (ts.valid-str? :some-lang "(some bad code"))))))

    (describe "get-node-at-cursor"
      (fn []
        (it "looks one column wider when get_node returns the whole document"
          (fn []
            (let [saved-get-node vim.treesitter.get_node
                  document {:parent (fn [] nil)
                            :named_descendant_for_range (fn [_ ...] [...])}]
              (tset vim.treesitter :get_node (fn [] document))
              (vim.api.nvim_win_set_cursor 0 [1 0])
              (let [range (ts.get-node-at-cursor)]
                (tset vim.treesitter :get_node saved-get-node)
                (assert.same [0 0 0 1] range)))))))))
