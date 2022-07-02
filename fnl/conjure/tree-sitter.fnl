(module conjure.tree-sitter
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             client conjure.client
             config conjure.config
             text conjure.text}})

;; From https://github.com/savq/conjure-julia <3

(def- ts
  (let [(ok? x) (pcall #(require :nvim-treesitter.ts_utils))]
    (when ok?
      x)))

(defn enabled? []
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

(defn node->str [node]
  "Turn the node into a string, nils flow through. Separate forms are joined by
  new lines."
  (when node
    (if (= 1 (nvim.fn.has "nvim-0.7"))
      (vim.treesitter.query.get_node_text node (nvim.get_current_buf))
      (-> (vim.treesitter.query.get_node_text node)
          (->> (str.join "\n"))))))

(defn parent [node]
  "Get the parent if possible."
  (when node
    (node:parent)))

(defn document? [node]
  "Is the node the entire document, i.e. has no parent?"
  (not (parent node)))

(defn range [node]
  "Get the character range of the form."
  (when node
    (let [(sr sc er ec) (node:range)]
      {:start [(a.inc sr) sc]
       :end [(a.inc er) (a.dec ec)]})))

(defn get-root [node]
  "Get the root node below the entire document."
  (let [node (or node (ts.get_node_at_cursor))
        parent-node (parent node)]
    (if
      (document? node) nil
      (document? parent-node) node
      (client.optional-call :comment-form? parent-node) node
      (get-root parent-node))))

(defn leaf? [node]
  "Does the node have any children? Or is it the end of the tree?"
  (when node
    (= 0 (node:child_count))))

(defn get-leaf [node]
  "Return the leaf node under the cursor or nothing at all."
  (let [node (or node (ts.get_node_at_cursor))]
    (when (leaf? node)
      node)))

(defn node-surrounded-by-form-pair-chars? [node extra-pairs]
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

(defn get-form [node]
  "Get the current form under the cursor. Walks up until it finds a non-leaf."
  (let [node (or node (ts.get_node_at_cursor))]
    (if
      ;; If we're already at the root then we're not in a form.
      (document? node)
      nil

      ;; Something with 0 children or whatever the client defines as not
      ;; a form-node isn't right. So we walk up further until we find a
      ;; good form to work with.
      (or (leaf? node)
          (= false (client.optional-call :form-node? node)))
      (get-form (parent node))

      ;; If we make it this far we have a true form node.
      node)))
