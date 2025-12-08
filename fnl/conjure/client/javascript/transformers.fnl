(local {: define : autoload } (require :conjure.nfnl.module))
(local eval (autoload :conjure.eval))
(local tsc (autoload :conjure.client.javascript.ts-common))
(local ir (autoload :conjure.client.javascript.import-replacer))
(local log (autoload :conjure.log))
(local a (autoload :conjure.nfnl.core))

(local M (define :conjure.client.javascript.transformers))

(var node-handlers {})

(fn handle-transform-error [err]
  (let [opts (or (. eval.previous-evaluations  "conjure.client.javascript.stdio") {})
        {:range range} opts
        {:start start} (or range {})
        [line col] (or start [])
        {:ln eline :col ecol :info einfo} (if (= "table" (type err)) err {})
        final-line (+ (or line 0) (or eline 0)) 
        final-col (if ecol (+ 1 ecol) col)
        info (or einfo "no info")]
    (log.append [(.. "/* [ERROR] transforming node " 
                     "at line " final-line
                     " column " final-col
                     ". Info: " info " */")])))

(fn transform [node code]
  (let [node-type (node:type)
        handler (or (. node-handlers node-type) node-handlers.default)
        (_ok result) (xpcall (fn [] (handler node code)) handle-transform-error)]
    result))

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

(fn forbidden-kw? [n code]
    (let [t (n:type)
          txt (tsc.get-text n code)]
      (or (= t "this")
          (= t "super")
          (= t "meta_property")
          (and (= t "identifier") (= txt "arguments"))
          (= txt "new.target"))))

(fn body-contains-forbidden-keyword? [node code]
  (let [stack [node]]
    (var found nil)
    (while (and (not found) (next stack))
      (let [n (table.remove stack)]
        (if (forbidden-kw? n code)
            (set found n)
            (each [c (n:iter_children)]
              (table.insert stack c)))))
    found))

(fn transform-arrow-fn [arrow-fn name code]
  (let [body-node (tsc.get-child arrow-fn "body")
        forbidden (body-contains-forbidden-keyword? body-node code)]
    (if forbidden
        (let [(ln col) (forbidden:start)]
          (error {:info (.. "Cannot transform arrow function, it contains '" (forbidden:type) "'")
                  :ln ln
                  :col col}))
        (let [params (tsc.get-text (tsc.get-child arrow-fn "parameters") code)
              body-text (transform body-node code)
              first-child (arrow-fn:child 0)
              async? (and first-child (= (first-child:type) "async"))
              async-kw (if async? "async " "")
              final-body (case (body-node:type)
                           "statement_block" (.. " " body-text)
                           "parenthesized_expression" (.. " { return " body-text " }")
                           _ (.. " { return " body-text " }"))]
          (.. async-kw "function " name params final-body)))))

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

(set node-handlers.export_statement
     (fn [node code]
       (let [child (node:child 1)]
         (case (child:type)
           (where (or "interface_declaration" "class_declaration")) 
           (node-handlers.default node code)

           "export_clause" ""

           _ (node-handlers.default child code)))))

(each [_ t (pairs
             [:expression_statement
              :variable_declaration
              :return_statement
              :throw_statement
              :break_statement
              :continue_statement
              :debugger_statement
              :class_declaration
              :field_definition
              :public_field_definition
              :function_declaration ])]

  (set (. node-handlers t) handle-statement))

(fn M.transform [s]
  (let [tree (tsc.get-tree s)
        root (tree:root)
        transformed (transform root s)]
    (string.gsub transformed "%s*\n%s*" " ")))

M
