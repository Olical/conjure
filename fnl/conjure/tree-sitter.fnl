(local {: autoload} (require :nfnl.module))
(local a (autoload :nfnl.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))

;; Initially based on https://github.com/savq/conjure-julia <3

(local ts
  (let [(ok? x) (pcall #(require :nvim-treesitter.ts_utils))]
    (when ok?
      x)))

(fn enabled? []
  "Do we have tree-sitter support in the current nvim, buffer and filetype. If
  this is false, you might need to install
  https://github.com/nvim-treesitter/nvim-treesitter
  and then `:TSInstall [filetype]`

  See also: g:conjure#extract#tree_sitter#enabled"
  (if (and
        (= :table (type ts))
        (config.get-in [:extract :tree_sitter :enabled])
        (let [(ok? parser) (pcall vim.treesitter.get_parser)]
          (and ok? parser)))
    true
    false))

(fn parse! []
  (let [(ok? parser) (pcall vim.treesitter.get_parser)]
    (if ok?
      (parser:parse))))

(fn node->str [node]
  "Turn the node into a string, nils flow through. Separate forms are joined by
  new lines."
  (when node
    (if vim.treesitter.get_node_text
      (vim.treesitter.get_node_text node (nvim.get_current_buf))
      (vim.treesitter.query.get_node_text node (nvim.get_current_buf)))))

(fn lisp-comment-node? [node]
  "Node is a (comment ...) form"
  (text.starts-with (node->str node) "(comment"))

(fn parent [node]
  "Get the parent if possible."
  (when node
    (node:parent)))

(fn document? [node]
  "Is the node the entire document, i.e. has no parent?"
  (not (parent node)))

(fn range [node]
  "Get the character range of the form."
  (when node
    (let [(sr sc er ec) (node:range)]
      {:start [(a.inc sr) sc]
       :end [(a.inc er) (a.dec ec)]})))

(fn node->table [node]
  "If it is a node, convert it to a Lua table we can work with in Conjure. If
  it's already a table with the right keys just return that."
  (if
    (and (a.get node :range) (a.get node :content))
    node

    node
    {:range (range node)
     :content (node->str node)}

    nil))

(fn get-root [node]
  "Get the root node below the entire document."
  (parse!)

  (let [node (or node (ts.get_node_at_cursor))
        parent-node (parent node)]
    (if
      (document? node) nil
      (document? parent-node) node
      (client.optional-call :comment-node? parent-node) node
      (get-root parent-node))))

(fn leaf? [node]
  "Does the node have any children? Or is it the end of the tree?"
  (when node
    (= 0 (node:child_count))))

;; Some node types I've seen: sym_lit, symbol, multi_symbol...
;; So I'm not sure if each language just picks a flavour, but this should cover all of our bases.
;; Clients can also opt in and hint with their own symbol-node? functions now too.
(fn sym? [node]
  (when node
    (or (string.find (node:type) :sym)
        (client.optional-call :symbol-node? node))))

(fn get-leaf [node]
  "Return the leaf node under the cursor or nothing at all."
  (parse!)

  (let [node (or node (ts.get_node_at_cursor))]
    (when (or (leaf? node) (sym? node))
      (var node node)
      (while (sym? (parent node))
        (set node (parent node)))
      node)))

(fn node-surrounded-by-form-pair-chars? [node extra-pairs]
  (let [node-str (node->str node)
        first-and-last-chars (text.first-and-last-chars node-str)]
    (or (a.some
          (fn [[start end]]
            (= first-and-last-chars (.. start end)))
          (config.get-in [:extract :form_pairs]))
        (a.some
          (fn [[start end]]
            (and (text.starts-with node-str start)
                 (text.ends-with node-str end)))
          extra-pairs)
        false)))

(fn node-prefixed-by-chars? [node prefixes]
  (let [node-str (node->str node)]
    (or (a.some
          (fn [prefix]
            (text.starts-with node-str prefix))
          prefixes)
        false)))

(fn get-form [node]
  "Get the current form under the cursor. Walks up until it finds a non-leaf.

  Warning, this can return a table containing content and range! Use
  node->table to normalise the types."

  ;; We assume we only use this argument in recursion, in which case we've
  ;; already called parse! and we shouldn't waste time calling it again, only
  ;; the first time.
  (when (not node)
    (parse!))

  (let [node (or node (ts.get_node_at_cursor))]
    (if
      ;; If we're already at the root then we're not in a form.
      (document? node)
      nil

      ;; We don't treat leaves as forms. That could be a single paren or quote
      ;; I think, so we walk upwards when we're on one.

      ;; The client can also return `false` from form-node? to walk upwards by
      ;; one level and try again. This is a strictly simpler and less powerful
      ;; alternative to get-form-modifier which allows you to specify the exact
      ;; node you wish to jump to. This is here for backwards compatibility and
      ;; simpler use cases. I recommend using get-form-modifier for new use
      ;; cases.
      (or (leaf? node)
          (= false (client.optional-call :form-node? node)))
      (get-form (parent node))

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
          (get-form (parent node))

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

{: enabled?
 : parse!
 : node->str
 : lisp-comment-node?
 : parent
 : document?
 : range
 : node->table
 : get-root
 : leaf?
 : sym?
 : get-leaf
 : node-surrounded-by-form-pair-chars?
 : node-prefixed-by-chars?
 : get-form}
