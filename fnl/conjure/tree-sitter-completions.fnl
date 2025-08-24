(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))
(local util (autoload :conjure.util))
(local res (autoload :conjure.resources))

(local M (define :conjure.tree-sitter-completions))

(local symbol-query-path-template "queries/%s/cmpl.scm")

(local query-cache {})

(fn build-completion-query [ts-lang cmpl-resource]
  (let [query-path (string.format symbol-query-path-template cmpl-resource)
        query-text (res.get-resource-contents query-path) ]
    (if query-text
      (vim.treesitter.query.parse ts-lang query-text)
      nil)))

(fn get-cached-completion-query [cmpl-resource]
  (let [cached-query (. query-cache cmpl-resource)]
    (if cached-query
      cached-query
      nil)))

(fn get-completion-query [ts-lang cmpl-resource]
  (let [cached-query (get-cached-completion-query cmpl-resource)]
    (if cached-query
      cached-query
      (let [query (build-completion-query ts-lang cmpl-resource)]
        (tset query-cache cmpl-resource query)
        query))))

(fn contains-node [nodes n]
  (if (= nil n)
      false
      (a.some #(n:equal $1) nodes)))

(fn get-scope-parent [node scopes]
  (if (or (= nil node) (= nil (node:parent)))
      nil

      (contains-node scopes (node:parent))
      (node:parent)

      (get-scope-parent (node:parent) scopes)))

(fn get-nth-scope-parent [n node scopes]
  (if (= n 0)
      node
      (get-nth-scope-parent (- n 1) (get-scope-parent node scopes) scopes)))

(fn get-node-scopes [node scopes matched-scopes]
  (let [acc (or matched-scopes [])
        next-scope (get-scope-parent node scopes)]
    (when (contains-node scopes node)
      (table.insert acc node))
    (if (= nil next-scope)
        acc
        (get-node-scopes next-scope scopes acc))))

(fn extract-scopes [query captures]
  (let [results []]
    (each [id n captures]
      (let [captured-label (. query.captures id)]
        (when (= :local.scope captured-label)
          (table.insert results n))))
    results))

(fn is-in-scope [target scope]
  (or (= nil scope) ; nil implies global scope
      (scope:equal target) 
      (vim.treesitter.is_ancestor scope target)))

(fn get-node-text [node buffer meta]
  (let [base-text (vim.treesitter.get_node_text node buffer)
        prefix (. meta :prefix)]
    (if prefix
        (.. prefix base-text)
        base-text)))

(fn get-completions-for-query [query]
  (let [buffer         (vim.api.nvim_get_current_buf)
        cursor-node    (ts.get-node-at-cursor) 
        (row _)        (unpack (vim.api.nvim_win_get_cursor 0))
        scope-captures (query:iter_captures (cursor-node:root) buffer 0 row)
        scopes         (extract-scopes query scope-captures)
        captures       (query:iter_captures (cursor-node:root) buffer 0 row) 
        results        []]

    (each [id n meta captures]
      (let [captured-label (. query.captures id)]
        (if (= :global.define captured-label)
            (table.insert results (get-node-text n buffer meta))

            (and (= :local.bind captured-label)
                 (not (cursor-node:equal (n:parent)))
                 (is-in-scope cursor-node (get-nth-scope-parent 1 n scopes)))
            (table.insert results (get-node-text n buffer meta))

            (and (= :local.define captured-label)
                 (not (cursor-node:equal (n:parent)))
                 (is-in-scope cursor-node (get-nth-scope-parent 2 n scopes)))
            (table.insert results (get-node-text n buffer meta)))))

    (util.ordered-distinct results)))

(fn M.get-completions-at-cursor [ts-lang cmpl-resource]
  "Use tree-sitter query to find completions in scope at cursor

  Arguments:
  - ts-lang: tree-sitter grammar language
  - cmpl-resource: query file resource path (queries/<cmpl-resource>/cmpl.scm)
  
  Returns:
  - deduplicated array of strings"
  (let [query (get-completion-query ts-lang cmpl-resource)]
    (if query
      (get-completions-for-query query)
      [])))

(fn M.make-prefix-filter [prefix]
  "Return function which filters words starting with prefix"
  (let [sanitized-prefix (string.gsub (or prefix "") "%%" "%%%%")
        prefix-pattern (.. "^" sanitized-prefix)
        prefix-filter (fn [s] (string.match s prefix-pattern))] 
    (fn [list] 
      (a.filter prefix-filter list))))

M
