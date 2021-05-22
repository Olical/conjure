(module conjure-local-fennel-config
  {require {nvim aniseed.nvim}})

; (set nvim.g.conjure#extract#tree_sitter#enabled true)
; (set nvim.g.conjure#client#clojure#nrepl#test#runner "kaocha")

(set package.path (.. package.path ";test/lua/?.lua"))
(set nvim.g.conjure#eval#gsubs {:do-comment ["^%(comment[%s%c]" "(do "]})

(comment
  (nvim.ex.augroup :conjure_set_state_key_on_dir_changed)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "DirChanged * call luaeval(\"require('conjure.client')['set-state-key!']('\" . getcwd() . \"')\")")
  (nvim.ex.augroup :END))
