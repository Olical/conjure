(module conjure.tree-sitter
  {require {a conjure.aniseed.core
            str conjure.aniseed.string
            client conjure.client}})

;; From https://github.com/savq/conjure-julia <3

;; TODO Add tree-sitter options and docs.
;; TODO Document new client interfaces for accepting nodes as forms.

(def- ts
  (let [(ok? x) (pcall #(require :nvim-treesitter.ts_utils))]
    (when ok?
      x)))

(defn enabled? []
  "Do we have tree-sitter support in the current nvim, buffer and filetype. If
  this is false, you might need to install
  https://github.com/nvim-treesitter/nvim-treesitter
  and then `:TSInstall [filetype]`"
  (and
    (= :table (type ts))
    (let [(ok? _) (pcall vim.treesitter.get_parser)]
      ok?)))

(defn node->str [node]
  "Turn the node into a string, nils flow through. Separate forms are joined by
  new lines."
  (when node
    (-> (ts.get_node_text node)
        (->> (str.join "\n")))))

(defn parent [node]
  "Get the parent if possible."
  (when node
    (node:parent)))

(defn document? [node]
  "Is the node the entire document, i.e. has no parent?"
  (not (parent node)))

(defn get-root [node]
  "Get the root node below the entire document."
  (let [node (or node (ts.get_node_at_cursor))
        p1 (parent node)
        p2 (parent p1)]
    (if (and p1 p2)
      (get-root p1)
      node)))

(defn leaf? [node]
  "Does the node have any children? Or is it the end of the tree?"
  (when node
    (= 0 (node:child_count))))

(defn get-leaf [node]
  "Return the leaf node under the cursor or nothing at all."
  (let [node (or node (ts.get_node_at_cursor))]
    (when (leaf? node)
      node)))

;; TODO This picks up things in Lisp land that I don't want to eval.
;; I need to implement form-node? for every client (or some similar idea?) that
;; allows clients to specify what kinds of nodes they consider an eval-able
;; form. Like for Lisps I probably want to check if the node as a string begins
;; with a parenthesis. Hammock time.
(defn get-form [node]
  "Get the current form under the cursor. Walks up until it finds a non-leaf."
  (let [node (or node (ts.get_node_at_cursor))]
    (if
      (or
        (document? node)
        (not= false (client.optional-call :form-node? node)))
      nil

      (leaf? node) (get-form (parent node))
      node)))

(node->str (get-form))
