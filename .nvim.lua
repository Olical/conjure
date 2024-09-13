-- [nfnl] Compiled from .nvim.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local reload = autoload("plenary.reload")
local notify = autoload("nfnl.notify")
vim.api.nvim_set_keymap("n", "<localleader>pt", "<Plug>PlenaryTestFile", {desc = "Run the current test file with plenary."})
vim.api.nvim_set_keymap("n", "<localleader>pT", "<cmd>PlenaryBustedDirectory lua/conjure-spec/<cr>", {desc = "Run all tests with plenary."})
local function _2_()
  notify.info("Reloading...")
  reload.reload_module("conjure")
  require("conjure.main")
  return notify.info("Done!")
end
vim.api.nvim_set_keymap("n", "<localleader>pr", "", {desc = "Reload the conjure modules.", callback = _2_})
vim.g["conjure#client#clojure#nrepl#refresh#backend"] = "clj-reload"
package.path = (package.path .. ";test/lua/?.lua")
vim.g["conjure#filetype#fennel"] = "conjure.client.fennel.nfnl"
--[[ (nvim.ex.augroup "conjure_set_state_key_on_dir_changed") (nvim.ex.autocmd_) (nvim.ex.autocmd "DirChanged * call luaeval(\"require('conjure.client')['set-state-key!']('\" . getcwd() . \"')\")") (nvim.ex.augroup "END") ]]
return nil
