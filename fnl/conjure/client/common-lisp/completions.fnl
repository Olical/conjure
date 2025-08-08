(local {: autoload : define} (require :conjure.nfnl.module))
(local tsc (autoload :conjure.tree-sitter-completions))
(local util (autoload :conjure.util))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-static-completions [prefix]
  (let [prefix-filter (util.make-prefix-filter prefix)] 
    (prefix-filter (tsc.get-completions-at-cursor
      :commonlisp ; This is the naming convention treesitter uses
      :common-lisp ))))

M
