-- [nfnl] Compiled from .nvim.fnl by https://github.com/Olical/nfnl, do not edit.
vim.g["conjure#client#clojure#nrepl#refresh#backend"] = "clj-reload"
package.path = (package.path .. ";test/lua/?.lua")
--[[ (nvim.ex.augroup "conjure_set_state_key_on_dir_changed") (nvim.ex.autocmd_) (nvim.ex.autocmd "DirChanged * call luaeval(\"require('conjure.client')['set-state-key!']('\" . getcwd() . \"')\")") (nvim.ex.augroup "END") ]]
return nil
