(local {: define : autoload } (require :conjure.nfnl.module))
(local tsc (autoload :conjure.client.javascript.ts-common))
(local ir (autoload :conjure.client.javascript.import-replacer))

(local M (define :conjure.client.javascript.transformers))

(var node-handlers {})

(fn transform [node code]
  (let [node-type (node:type)
        handler (or (. node-handlers node-type) node-handlers.default)]
    (let [(_ok result)
          (xpcall
            (fn [] (handler node code))
            (fn [err]
              (.. "/* [ERROR] transforming node " node-type ": " err " */")))]
      result)))

(set node-handlers.default
     (fn [node code]
       (if (= (node:child_count) 0)
           (tsc.get-text node code)
           (let [pieces []]
             (var prev-end (let [(_ _ b) (node:start)] b))
             (each [child (node:iter_children)]
               (let [(_ _ start) (child:start)
                     (_ _ stop) (child:end_)]
                 (table.insert pieces (string.sub code (+ prev-end 1) start))
                 (table.insert pieces (transform child code))
                 (set prev-end stop)))
             (table.insert pieces (string.sub code (+ prev-end 1) (let [(_ _ end) (node:end_)] end)))
             (table.concat pieces "")))))

(set node-handlers.comment
  (fn [_ _] ""))

(fn transform-arrow-fn [arrow-fn name code]
  (let [params (tsc.get-text (tsc.get-child arrow-fn "parameters") code)
        body-node (tsc.get-child arrow-fn "body")
        body-text (transform body-node code)
        first-child (arrow-fn:child 0)
        async? (and first-child (= (first-child:type) "async"))
        async-kw (if async? "async " "")
        final-body (case (body-node:type)
                     "statement_block" (.. " " body-text)
                     "parenthesized_expression" (.. " { return " body-text " }")
                     _ (.. " { return " body-text " }"))]
    (.. async-kw "function " name params final-body)))

(fn handle-statement [node code]
  (let [text (node-handlers.default node code)
        trimmed (vim.fn.trim text)
        last-char (string.sub trimmed -1)]
    (if (or (= last-char ";")
            (= last-char ":"))
        text
        (.. text ";"))))

(set node-handlers.lexical_declaration
     (fn [node code]
       (let [var-decl (node:child 1)
             value-node (and var-decl
                             (= (var-decl:type) "variable_declarator")
                             (tsc.get-child var-decl "value"))]
         (if (and value-node (= "arrow_function" (value-node:type)))
             (let [name (tsc.get-text (tsc.get-child var-decl "name") code)]
               (transform-arrow-fn value-node name code))
             (handle-statement node code)))))

(set node-handlers.member_expression
     (fn [node code]
       (let [obj (. (node:field "object") 1)]
         (if (and obj (or (= (obj:type) "call_expression") (= (obj:type) "member_expression")))
             (let [default-text (node-handlers.default node code)
                   flattened (string.gsub default-text "%s*\n%s*" "")]
               flattened)
             (node-handlers.default node code)))))

(set node-handlers.import_statement
     (ir.import-statement handle-statement))

(set node-handlers.call_expression
     (ir.call-expression node-handlers.default))

(each [_ t (pairs
             [:expression_statement
              :variable_declaration
              :return_statement
              :throw_statement
              :break_statement
              :continue_statement
              :debugger_statement
              :export_statement
              :class_declaration
              :field_definition
              :public_field_definition
              :function_declaration])]
  (set (. node-handlers t) handle-statement))

(fn M.transform [s]
  (let [tree (tsc.get-tree s)
        root (tree:root)
        transformed (transform root s)]
    (string.gsub transformed "%s*\n%s*" " ")))

M
