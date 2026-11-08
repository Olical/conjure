(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))

;; Initially based on https://github.com/savq/conjure-julia <3

(local M (define :conjure.tree-sitter))

(fn M.enabled? []
  "Do we have tree-sitter support in the current nvim, buffer and filetype. If
  this is false, you might need to install
  https://github.com/nvim-treesitter/nvim-treesitter
  and then `:TSInstall [filetype]`

  See also: g:conjure#extract#tree_sitter#enabled"
  (if (and
        (config.get-in [:extract :tree_sitter :enabled])
        (let [(ok? parser) (pcall vim.treesitter.get_parser)]
          (and ok? parser)))
    true
    false))

(fn M.parse! []
  (let [(ok? parser) (pcall vim.treesitter.get_parser)]
    (if (and ok? (not= nil parser))
      (parser:parse))))

(fn M.node->str [node]
  "Turn the node into a string, nils flow through. Separate forms are joined by
  new lines."
  (when node
    (if vim.treesitter.get_node_text
      (vim.treesitter.get_node_text node (vim.api.nvim_get_current_buf))
      (vim.treesitter.query.get_node_text node (vim.api.nvim_get_current_buf)))))

(fn M.lisp-comment-node? [node]
  "Node is a (comment ...) form"
  (text.starts-with (M.node->str node) "(comment"))

(fn M.parent [node]
  "Get the parent if possible."
  (when node
    (node:parent)))

(fn M.document? [node]
  "Is the node the entire document, i.e. has no parent?"
  (not (M.parent node)))

(fn M.range [node]
  "Get the character range of the form."
  (when node
    (let [(sr sc er ec) (node:range)]
      {:start [(a.inc sr) sc]
       :end [(a.inc er) (a.dec ec)]})))

(fn M.node->table [node]
  "If it is a node, convert it to a Lua table we can work with in Conjure. If
  it's already a table with the right keys just return that."
  (if
    (and (a.get node :range) (a.get node :content))
    node

    node
    {:range (M.range node)
     :content (M.node->str node)
     :node node}

    nil))

(fn M.get-node-at-cursor []
  "The named node under the cursor, like vim.treesitter.get_node.

  Some grammars give the document a zero width first child, such as
  tree-sitter-r's `_start`, which makes get_node return the document itself
  at (0, 0). So when we get the document we look one column wider to find the
  real node."
  (let [node (vim.treesitter.get_node)]
    (if (and node (M.document? node))
      (let [[row col] (vim.api.nvim_win_get_cursor 0)
            row (a.dec row)]
        (node:named_descendant_for_range row col row (a.inc col)))
      node)))

(fn M.get-root [node]
  "Get the root node below the entire document."
  (M.parse!)

  (let [node (or node (M.get-node-at-cursor))
        parent-node (M.parent node)]
    (if
      (M.document? node) nil
      (M.document? parent-node) node
      (client.optional-call :comment-node? parent-node) node
      (M.get-root parent-node))))

(fn M.leaf? [node]
  "Does the node have any children? Or is it the end of the tree?"
  (when node
    (= 0 (node:child_count))))

;; Some node types I've seen: sym_lit, symbol, multi_symbol...
;; So I'm not sure if each language just picks a flavour, but this should cover all of our bases.
;; Clients can also opt in and hint with their own symbol-node? functions now too.
(fn M.sym? [node]
  (when node
    (or (string.find (node:type) :sym)
        (= (node:type) :package_lit) ;; just for common lisp
        (vim.tbl_contains [:field_expression :scoped_identifier] (node:type)) ;; just for julia
        (client.optional-call :symbol-node? node))))

(fn M.get-leaf [node]
  "Return the leaf node under the cursor or nothing at all."
  (M.parse!)

  (let [node (or node (M.get-node-at-cursor))]
    (when (or (M.leaf? node) (M.sym? node))
      (var node node)
      (while (M.sym? (M.parent node))
        (set node (M.parent node)))
      node)))

(fn M.node-surrounded-by-form-pair-chars? [node extra-pairs]
  (let [node-str (M.node->str node)
        first-and-last-chars (text.first-and-last-chars node-str)]
    (or (a.some
          (fn [[start end]]
            (= first-and-last-chars (.. start end)))
          (config.get-in [:extract :form_pairs]))
        (a.some
          (fn [[start end]]
            (and (vim.startswith node-str start)
                 (vim.endswith node-str end)))
          extra-pairs)
        false)))

(fn M.node-prefixed-by-chars? [node prefixes]
  (let [node-str (M.node->str node)]
    (or (a.some
          (fn [prefix]
            (vim.startswith node-str prefix))
          prefixes)
        false)))

(fn M.get-form [node]
  "Get the current form under the cursor. Walks up until it finds a non-leaf.

  Warning, this can return a table containing content and range! Use
  node->table to normalise the types."

  ;; We assume we only use this argument in recursion, in which case we've
  ;; already called parse! and we shouldn't waste time calling it again, only
  ;; the first time.
  (when (not node)
    (M.parse!))

  (let [node (or node (M.get-node-at-cursor))]
    (if
      ;; If we're already at the root then we're not in a form.
      (M.document? node)
      nil

      ;; We don't treat leaves as forms. That could be a single paren or quote
      ;; I think, so we walk upwards when we're on one.

      ;; The client can also return `false` from form-node? to walk upwards by
      ;; one level and try again. This is a strictly simpler and less powerful
      ;; alternative to get-form-modifier which allows you to specify the exact
      ;; node you wish to jump to. This is here for backwards compatibility and
      ;; simpler use cases. I recommend using get-form-modifier for new use
      ;; cases.
      (or (M.leaf? node)
          (= false (client.optional-call :form-node? node)))
      (M.get-form (M.parent node))

      ;; Each client gets to modify the form, this means they can traverse the
      ;; tree until they find something they're happy with. The client should
      ;; return `nil` or a :modifier of :none when they're happy.
      (let [{: modifier &as res} (or (client.optional-call :get-form-modifier node) {})]
        (if
          ;; A client not participating,  explicitly returning `nil` or a
          ;; :modifier of :none indicates that they're happy with the form and
          ;; we can use it.
          (or (not modifier) (= :none modifier))
          node

          ;; Walk upwards by one.
          (= :parent modifier)
          (M.get-form (M.parent node))

          ;; An actual node! Use that one.
          (= :node modifier)
          (. res :node)

          ;; A raw table response, skipping the tree sitter node entirely.
          ;; Better hope people calling get-form can handle tree sitter AND
          ;; table responses!
          (= :raw modifier)
          (. res :node-table)

          ;; Otherwise we don't recognise this modifier.
          ;; Try to keep things working but log a warning!
          ;; This is a bug in the client and it needs to be fixed.
          (do
            (a.println "Warning: Conjure client returned an unknown get-form-modifier" res)
            node))))))

(fn M.add-language [lang]
  (let [add (case vim.treesitter
              {:language {:add f}} f
              {:language {:require_language f}} (partial pcall f)
              {:require_language f} (partial pcall f))]
    (add lang)))

(fn get-root-node-for-str [lang code]
  (let [parser (vim.treesitter.get_string_parser code lang)]
    (parser:parse)
    (let [trees (parser:trees)]
      (when (and trees
                 (> (length trees) 0))
        (let [root-tree (. trees 1)]
          (root-tree:root))))))

(fn M.valid-str? [lang code]
  (if (M.enabled?)
    (let [root-node (get-root-node-for-str lang code)]
      (and root-node
           (not (root-node:has_error))))
    true))

M
