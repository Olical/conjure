(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local conjure-ts (autoload :conjure.tree-sitter))
(local ts-utils (autoload :nvim-treesitter.ts_utils))
(local vim-ts (autoload :vim.treesitter))
(local fennel (autoload :nfnl.fennel))
(local notify (autoload :nfnl.notify))
(local config (autoload :nfnl.config))
(local {: get-buf-content-as-string} (autoload :nfnl.nvim))

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

(fn get-current-root [bufnr lang]
  "Return the root-node of bufnr or current buffer"
  (let [bufnr (or bufnr 0)
        lang (or lang :fennel)
        parser (vim-ts.get_parser bufnr lang)
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
  (let [curr-targets (search-targets def-query (get-current-root bufnr) bufnr
                                     last-row)
        results (core.filter (fn [node-t]
                               (= code-text node-t.content))
                             curr-targets)]
    results))

(fn search-ext-targets [query root-node bufnr last]
  "Based on the TS:Query, root-node, bufnr, list all the possible search targets.
   bufnr is ext-buffer, so that we cannot access node.content directly."
  (let [last (or last -1)
        lines (vim.api.nvim_buf_get_lines bufnr 0 -1 false)]
    (icollect [id node (query:iter_captures root-node bufnr 0 last)]
      (let [range (conjure-ts.range node)
            start-row (core.get-in range [:start 1])
            start-col (core.get-in range [:start 2])
            end-row (core.get-in range [:end 1])
            end-col (core.get-in range [:end 2])]
        (let [content (string.sub (core.get lines start-row) (+ 1 start-col)
                                  (+ 1 end-col))]
          {: content : range})))))

(fn search-in-ext-buffer [code-text last-row bufnr]
  "Search defs inside ext buffer (not current buffer)"
  (let [curr-targets (search-ext-targets def-query (get-current-root bufnr)
                                         bufnr last-row)
        results (core.filter (fn [node-t]
                               (= code-text node-t.content))
                             curr-targets)]
    results))

(fn jump-to-range [range]
  (vim.api.nvim_win_set_cursor 0 range.start))

(fn rest-str [s]
  "equal to clojure's (str (rest s))"
  (string.sub s 2 -1))

(fn resolve-lua-module-path [modname]
  "Try to resolve a lua module via package.path"
  (package.searchpath (.. :lua. modname) package.path))

(fn resolve-fnl-module-path [modname]
  "Try to resolve a fnl module via fennel.path"
  (package.searchpath modname (. (config.default) :fennel-path)))

(fn imported-modules [resolve last-row]
  "Return a list of resolved file paths for all require/autoload modules in current buffer."
  (let [root (get-current-root) ;; find out all the import module symbol
        raw-mods (icollect [_ node-t (ipairs (search-targets path-query root 0
                                                             last-row))]
                   (rest-str node-t.content))]
    ;; resolve them all
    (icollect [_ m (ipairs raw-mods)]
      (resolve m))))

(comment (icollect [id node_t (ipairs (search-targets path-query
                                                      (get-current-root) 0 30))]
           (rest-str node_t.content))
  (imported-modules resolve-fnl-module-path -1))

(fn search-in-ext-file [code-text file-path]
  "Open file-path buffer, search for code-text, and jump if found."
  (let [bufnr (vim.fn.bufadd file-path)]
    (vim.fn.bufload bufnr)
    (let [cross-results (search-in-ext-buffer code-text -1 bufnr)]
      (when (> (length cross-results) 0)
        (vim.api.nvim_set_current_buf bufnr)
        (jump-to-range (. (core.last cross-results) :range))
        (core.last cross-results)
        (lua "return 1"))
      (vim.api.nvim_buf_delete bufnr {}))))

(comment ;; init
  (local f
         :/Users/laurencechen/.local/share/nvim/plugged/nfnl/fnl/nfnl/notify.fnl)
  (local bufnr (vim.fn.bufadd f))
  (vim.fn.bufload bufnr)
  (search-ext-targets def-query (get-current-root bufnr :fennel) bufnr)
  (search-in-ext-buffer :debug -1 bufnr)
  (search-in-ext-file :debug f))

(fn remove-module-name [s]
  (let [(start-index end-index) (string.find s "%.")]
    (if start-index
        (string.sub s (+ 1 start-index))
        s)))

(fn search-and-jump [code-text last-row]
  "Try jump in local file and fennel modules"
  (let [results (search-in-buffer code-text last-row 0)
        fnl-imports (imported-modules resolve-fnl-module-path last-row)]
    (if (> (length results) 0) ;; local jump
        (do
          (let [node (core.last results)]
            (jump-to-range node.range))
          results)
        (> (length fnl-imports) 0) ;; cross fnl module jump
        (do
          (each [_ file-path (ipairs fnl-imports)]
            (let [code-text (remove-module-name code-text)
                  r (search-in-ext-file code-text file-path)]
              (when r (lua "return r"))))
          {:result "definition not found"}))))

(comment ;;
  (search-and-jump :search-and-jump 39)
  (search-and-jump :search-and-jump 49)
  ;; 
  )

{: search-and-jump : search-targets : def-query : get-current-root}
