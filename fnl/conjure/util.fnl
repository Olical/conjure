(module conjure.util
  {autoload {nvim conjure.aniseed.nvim}})

(defn wrap-require-fn-call [mod f]
  (fn [...]
    ((. (require mod) f) ...)))

(defn replace-termcodes [s]
  (nvim.replace_termcodes s true false true))
