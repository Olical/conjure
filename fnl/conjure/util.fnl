(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))

(local M (define :conjure.util))

(fn M.wrap-require-fn-call [mod f]
  "We deliberately don't pass args through here because functions can behave
  very differently if they blindly accept args. If you need the args you should
  do your own function wrapping and not use this shorthand."
  (fn []
    ((. (require mod) f))))

(fn M.replace-termcodes [s]
  (vim.api.nvim_replace_termcodes s true false true))

(fn M.ordered-distinct [l]
  (let [seen   {}
        result []]
    (each [_ v (ipairs l)]
      (when (not (a.get seen v) )
        (a.assoc seen v true)
        (table.insert result v)))
    result))

M
