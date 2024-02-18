(fn wrap-require-fn-call [mod f]
  "We deliberately don't pass args through here because functions can behave
  very differently if they blindly accept args. If you need the args you should
  do your own function wrapping and not use this shorthand."
  (fn []
    ((. (require mod) f))))

(fn replace-termcodes [s]
  (vim.api.nvim_replace_termcodes s true false true))

{: wrap-require-fn-call
 : replace-termcodes}
