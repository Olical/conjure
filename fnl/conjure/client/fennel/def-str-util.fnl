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

;;TSQuery that matches the module path imported by `require, autoload`
(local path-query (vim-ts.query.parse :fennel
"
(local_form
  (binding_pair
    rhs: (list
           call: (symbol) (#any-of? \"autoload\" \"require\")
           item: (string) @import.path)))"))

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

(fn search-in-buffer [code-text last-row bufnr]
  "Search defs inside one buffer"
  (let [curr-targets (search-targets def-query (get-current-root) bufnr last-row)
        results (core.filter (fn [node-t]
                               (= code-text node-t.content))
                             curr-targets)]
    results))

(fn jump-to-range [range]
  (vim.api.nvim_win_set_cursor 0 range.start))

(fn search-and-jump [code-text last-row]
  "Try jump in current file"
  (let [results (search-in-buffer code-text last-row 0)]
    (if (> (length results) 0)
        (do
          (let [node (core.last results)]
            (jump-to-range node.range))
          results)
        {:result "definition not found"})))

(comment ;;
  (search-and-jump :search-and-jump 39)
  (search-and-jump :search-and-jump 49)
  ;; 
  )

(fn rest-str [s]
  "equal to clojure's (str (rest s))"
  (string.sub s 2 -1))

(comment
 (icollect [id node_t (ipairs (search-targets path-query (get-current-root) 0 30))]
  (rest-str node_t.content)))
 
(fn resolve-module-path [modname]
  "Try to resolve a lua module to actual file path."
  (package.searchpath modname package.path))

(fn imported-modules []
  "Return a list of resolved file paths for all require/autoload modules in current buffer."
  (let [root (get-current-root)
        ;; find out all the import module symbol
        raw-mods (icollect [_ node-t (ipairs (search-targets path-query root 0 200))]
                   (rest-str node-t.content))]
    ;; resolve them all 
    (icollect [_ m (ipairs raw-mods)]
      (resolve-module-path m))))

(imported-modules)

{: search-and-jump
 : search-targets
 : def-query
 : get-current-root}


