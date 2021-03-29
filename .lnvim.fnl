(module conjure-local-fennel-config
  {require {nvim aniseed.nvim}})

; (set nvim.g.conjure#extract#tree_sitter#enabled true)

(set nvim.g.conjure#client#clojure#nrepl#test#runner_namespace "kaocha.repl")
(set nvim.g.conjure#client#clojure#nrepl#test#all_fn "run")
(set nvim.g.conjure#client#clojure#nrepl#test#ns_fn "run")
(set nvim.g.conjure#client#clojure#nrepl#test#var_fn "run")
(set nvim.g.conjure#client#clojure#nrepl#test#var_prefix "")
(set nvim.g.conjure#client#clojure#nrepl#test#var_suffix "")

(set package.path (.. package.path ";test/lua/?.lua"))

(comment
  (do
    (nvim.ex.augroup :conjure_set_state_key_on_dir_changed)
    (nvim.ex.autocmd_)
    (nvim.ex.autocmd
      "DirChanged * call luaeval(\"require('conjure.client')['set-state-key!']('\" . getcwd() . \"')\")")
    (nvim.ex.augroup :END)))
