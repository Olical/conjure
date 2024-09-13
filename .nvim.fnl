(local {: autoload} (require :nfnl.module))
(local reload (autoload :plenary.reload))
(local notify (autoload :nfnl.notify))

(vim.api.nvim_set_keymap
  :n "<localleader>pt" "<Plug>PlenaryTestFile" {:desc "Run the current test file with plenary."})

(vim.api.nvim_set_keymap
  :n "<localleader>pT" "<cmd>PlenaryBustedDirectory lua/conjure-spec/<cr>" {:desc "Run all tests with plenary."})

(vim.api.nvim_set_keymap
  :n "<localleader>pr" ""
  {:desc "Reload the conjure modules."
   :callback (fn []
               (notify.info "Reloading...")
               (reload.reload_module "conjure")
               (require :conjure.main)
               (notify.info "Done!"))})

; (set vim.g.conjure#extract#tree_sitter#enabled true)
; (set vim.g.conjure#client#clojure#nrepl#test#runner "kaocha")
; (set vim.g.conjure#filetype#fennel "conjure.client.fennel.stdio")
; (set vim.g.conjure#filetype#scheme "conjure.client.snd-s7.stdio")
; (set vim.g.conjure#debug true)

; (set vim.g.conjure#client#scheme#stdio#command "csi -quiet -:c")
; (set vim.g.conjure#client#scheme#stdio#prompt_pattern "\n-#;%d-> ")
; (set vim.g.conjure#mapping#enable_defaults false)

; (set vim.g.conjure#filetype#scheme "conjure.client.guile.socket")
; (set vim.g.conjure#client#guile#socket#pipename "guile-repl.socket")

; (set vim.g.conjure#client#python#stdio#command "ipython --classic")

(set vim.g.conjure#client#clojure#nrepl#refresh#backend "clj-reload")

(set package.path (.. package.path ";test/lua/?.lua"))
; (set vim.g.conjure#eval#gsubs {:do-comment ["^%(comment[%s%c]" "(do "]})

(set vim.g.conjure#filetype#fennel "conjure.client.fennel.nfnl")

(comment
  (nvim.ex.augroup :conjure_set_state_key_on_dir_changed)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "DirChanged * call luaeval(\"require('conjure.client')['set-state-key!']('\" . getcwd() . \"')\")")
  (nvim.ex.augroup :END))
