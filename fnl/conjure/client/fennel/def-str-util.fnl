(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local conjure-ts (autoload :conjure.tree-sitter))
(local vim-ts (autoload :vim.treesitter))
(local config (autoload :conjure.nfnl.config))
(local notify (autoload :conjure.nfnl.notify))
(local res (autoload :conjure.resources))

;;TSQuery that matches `local, fn, M.fn`
(local def-local-query (vim-ts.query.parse
                         :fennel
                         (res.get-resource-contents "queries/fennel/local-def.scm")))

;;TSQuery that matches `local, fn, M.(fn) `
(local def-ext-query (vim-ts.query.parse
                       :fennel
                       (res.get-resource-contents "queries/fennel/ext-def.scm")))

;;TSQuery that matches the module path imported by `require, autoload`
(local path-query (vim-ts.query.parse
                    :fennel
                    (res.get-resource-contents "queries/fennel/import-path.scm")))

(fn get-current-root [bufnr lang]
  "Return the root-node of bufnr or current buffer"
  (let [bufnr (or bufnr 0)
        lang (or lang :fennel)
        parser (vim-ts.get_parser bufnr lang)
        tree (. (parser:parse) 1)]
    (tree:root)))

(fn search-targets [query root-node bufnr last first]
  "Based on the TS:Query, root-node, bufnr, list all the possible search targets"
  ;; Return data like 
  ;; [{:content "conjure-ts"
  ;;   :node #<<node symbol_binding>>
  ;;   :range {:end [2 16] :start [2 7]}}
  ;;  ...
  (let [bufnr (or bufnr 0)
        last (or last (- 1))
        first (or first 0)]
    (icollect [id node (query:iter_captures root-node bufnr first last)]
      (conjure-ts.node->table node))))

(comment (search-targets def-local-query (get-current-root) 0 20))

(fn search-in-buffer [code-text last-row bufnr]
  "Search defs inside one buffer"
  (let [curr-targets (search-targets def-local-query (get-current-root bufnr) bufnr
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
  (let [curr-targets (search-ext-targets def-ext-query (get-current-root bufnr)
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

(fn imported-modules [resolve last-row first-row]
  "Return a list of resolved file paths for all require/autoload modules in current buffer."
  (let [root (get-current-root) ;; find out all the import module symbol
        raw-mods (icollect [_ node-t (ipairs (search-targets path-query root 0
                                                             last-row first-row))]
                   (rest-str node-t.content))]
    (notify.debug (.. "raw-mods: " (core.pr-str raw-mods)))
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
      (if (> (length cross-results) 0)
          (do
            ;; found
            (vim.api.nvim_set_current_buf bufnr)
            (jump-to-range (. (core.last cross-results) :range))
            (core.last cross-results)
            true)
          (do
            ;; not found
            (vim.api.nvim_buf_delete bufnr {})
            false)))))

(comment ;; init
  (local f
         :/Users/laurencechen/.local/share/nvim/plugged/nfnl/fnl/nfnl/notify.fnl)
  (local bufnr (vim.fn.bufadd f))
  (vim.fn.bufload bufnr)
  (search-ext-targets def-local-query (get-current-root bufnr :fennel) bufnr)
  (search-in-ext-buffer :debug -1 bufnr)
  (search-in-ext-file :debug f))

(fn fn-name [s]
  (let [(start-index _) (string.find s "%.")]
    (if start-index
        (string.sub s (+ 1 start-index))
        s)))

(fn module-name [s]
  (let [(start-index _) (string.find s "%.")]
    (if start-index
        (string.sub s 1 (- start-index 1))
        nil)))

(fn reverse [xs]
  (let [new-list []
        n (length xs)]
    (for [i n 1 -1]
      (table.insert new-list (. xs i)))
    new-list))

(fn cross-jump [fn-text fnl-imports]
  (notify.debug (.. "fnl-path: " (. (config.default) :fennel-path)))
  (notify.debug (.. "search symbol in the following fnl libs: "
                            (core.pr-str fnl-imports)))
  (let [results []]
    (each [_ file-path (ipairs fnl-imports)]
      (notify.debug (.. "search in file-path: " file-path
                          " for fn-text " fn-text ))
      (let [r (search-in-ext-file fn-text file-path)]
        (notify.debug (.. "get result " (tostring r) " from search"))
        (table.insert results r)))
        (when (not (core.some core.identity results))
          {:result "definition not found"})))

(fn search-and-jump [code-text last-row]
  "Try jump in local file and fennel modules"
  (notify.debug (.. "code-text: " code-text))
  (let [results (search-in-buffer code-text last-row 0)
        module-text (module-name code-text)
        module-results (search-in-buffer module-text last-row 0) 
        fn-text (fn-name code-text)
        fnl-imports (imported-modules resolve-fnl-module-path last-row)]
    (if (> (length results) 0) ;; local jump
        (do
          (let [node (core.last results)]
            (jump-to-range node.range))
          results)
        (> (length module-results) 0) ;; direct cross fnl module jump
        (do
          (notify.debug "begin direct cross fnl module jump to certain module")
          (notify.debug (core.str module-results))
          (let [target (core.first module-results)
                end-row  (core.get-in target [:range :end 1]) 
                fnl-imports (imported-modules resolve-fnl-module-path end-row (- end-row 1))]
            (cross-jump fn-text fnl-imports)))
        (> (length fnl-imports) 0) ;; cross fnl module jump
        (do 
          (notify.debug "begin cross fnl module jump")
          (let [r-fnl-imports (reverse fnl-imports)]
            (cross-jump fn-text r-fnl-imports)))
        )))

(comment ;;
  (search-and-jump :search-and-jump 39)
  (search-and-jump :search-and-jump 49)
  ;; 
  )

{: search-and-jump : search-targets : get-current-root : def-local-query : def-ext-query
 : path-query : imported-modules : resolve-fnl-module-path}
