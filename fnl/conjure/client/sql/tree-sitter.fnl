(local {: autoload : define} (require :conjure.nfnl.module))

(local config (autoload :conjure.config))
(local ts (autoload :conjure.tree-sitter))

(local cfg (config.get-in-fn [:client :sql :stdio]))

(local M (define :conjure.client.sql.tree-sitter))

(set M.statement-types {:statement true})
(set M.command-wrapper-types {:statement true :transaction true})

(fn M.ancestor-of-type [?node types]
  (if (or (= nil ?node) (?. types (?node:type)))
      ?node
      (tail! (M.ancestor-of-type (?node:parent) types))))

(fn M.relations [node]
  (let [rels []]
    (fn go [node]
      (each [child (node:iter_children)]
        (when (= :relation (child:type))
          (table.insert rels child))
        (go child)))
    (go node)
    rels))

(fn M.relation-parts [relation]
  (let [parts {}]
    (each [child (relation:iter_children)]
      (case (child:type)
        :object_reference (set parts.ref child)
        :identifier (set parts.alias child)))
    parts))

(fn M.alias->object-reference [?statement word]
  (when ?statement
    (accumulate [found nil _ relation (ipairs (M.relations ?statement)) &until found]
      (case (M.relation-parts relation)
        (where {: ref : alias} (= word (ts.node->str alias)))
        (ts.node->str ref)))))

(fn M.node-type [?node]
  (when ?node
    (?node:type)))

(fn M.child-of-type [node type]
  (accumulate [found nil child (node:iter_children) &until found]
    (when (= type (child:type))
      child)))

(fn M.reference-node [leaf]
  (let [parent (leaf:parent)]
    (case (M.node-type parent)
      :object_reference parent
      :field (M.child-of-type parent :object_reference)
      _ leaf)))

(local function-parents {:create_function true
                         :drop_function true
                         :invocation true})

(fn M.function-reference? [node]
  (?. function-parents (M.node-type (node:parent))))

(fn M.relation-name [leaf name]
  (case name
    (where dotted (dotted:find "%.")) dotted
    bare (or (M.alias->object-reference (M.ancestor-of-type leaf M.statement-types) bare) bare)))

(fn M.command-node [leaf]
  (case (M.ancestor-of-type leaf M.command-wrapper-types)
    wrapper (if (wrapper:equal (leaf:parent))
                leaf
                (wrapper:named_child 0))))

(fn M.doc-topic [node]
  (pick-values 1
    (-> (node:type)
        (string.gsub "^keyword_" "")
        (string.gsub "_statement$" "")
        (string.gsub "_" " "))))

(fn M.describe-at-cursor []
  (case (ts.get-leaf)
    (where leaf (vim.startswith (leaf:type) :keyword_))
    (case (M.command-node leaf)
      node {:command (cfg [:doc_statement]) :target (M.doc-topic node)})

    (where leaf (= :identifier (leaf:type)))
    (case (M.reference-node leaf)
      node (let [name (ts.node->str node)]
             (if (M.function-reference? node)
                 {:command (cfg [:doc_function]) :target name}
                 {:command (cfg [:doc_table])
                  :target (M.relation-name leaf name)})))))

M
