(local {: autoload : define} (require :conjure.nfnl.module))
(local tsc (autoload :conjure.tree-sitter-completions))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-static-completions [prefix]
  (let [prefix-filter (tsc.make-prefix-filter prefix)] 
    (prefix-filter (tsc.get-completions-at-cursor
      :commonlisp ; This is the naming convention treesitter uses
      :common-lisp ))))

M
