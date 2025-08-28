(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local conjure-ts (autoload :conjure.tree-sitter))
(local ts-utils (autoload :nvim-treesitter.ts_utils))
(local vim-ts (autoload :vim.treesitter))

;;TSQuery that matches `local, fn`
(local def-query (vim-ts.query.parse :fennel
                                     "
(local_form
 (binding_pair
   lhs: (symbol_binding) @local.def)) 
(fn_form
  name: [(symbol) (multi_symbol)] @fn.def)"))

(fn prt [t]
  (each [k v (pairs t)]
    (if (not= (type v) :table)
        (print k v)
        (do
          (print k)
          (prt v)))))

(fn get-current-root []
  "Return the root-node of current buffer"
  (let [bufnr 0
        parser (vim-ts.get_parser bufnr)
        tree (. (parser:parse) 1)]
    (tree:root)))

(fn search-targets [query root-node bufnr last]
  "Based on the TS:Query, root-node, bufnr, list all the possible search targets"
  ;; Return data like 
  ;; [{:content "conjure-ts"
  ;;   :node #<<node symbol_binding>>
  ;;   :range {:end [2 16] :start [2 7]}}
  ;;  ...
  (let [bufnr (or bufnr 0)
        last (or last (- 1))]
    (icollect [id node (query:iter_captures root-node bufnr 0 last)]
      (conjure-ts.node->table node))))

(comment (search-targets def-query (get-current-root) 0 20))

(fn search-and-jump [code-text last-row]
  (let [curr-targets (search-targets def-query (get-current-root) 0 last-row)
        results (core.filter (fn [node-t]
                               (= code-text node-t.content))
                             curr-targets)]
    (if (> (length results) 0)
        (do
          (let [node (core.last results)
                range node.range]
            (vim.api.nvim_win_set_cursor 0 range.start))
          results)
        {:result "definition not found"})))

(comment ;;
  (search-and-jump :search-and-jump 39)
  (search-and-jump :search-and-jump 49)
  ;; 
  )

{: search-and-jump : search-targets : def-query : get-current-root}
