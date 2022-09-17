(module conjure.util
  {autoload {nvim conjure.aniseed.nvim}})

(defn wrap-require-fn-call [mod f]
  "We deliberately don't pass args through here because functions can behave
  very differently if they blindly accept args. If you need the args you should
  do your own function wrapping and not use this shorthand."
  (fn []
    ((. (require mod) f))))

(defn replace-termcodes [s]
  (nvim.replace_termcodes s true false true))
