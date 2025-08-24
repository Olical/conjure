(local {: autoload } (require :conjure.nfnl.module))
(local tsc (autoload :conjure.tree-sitter-completions))

(var mock-completions [])

(fn set-mock-completions [r]
  (set mock-completions r))

(fn get-completions-at-cursor [_ _]
  mock-completions)

{: set-mock-completions 
 : get-completions-at-cursor
 :make-prefix-filter tsc.make-prefix-filter }

