-- [nfnl] Compiled from fnl/nfnl/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local callback = autoload("nfnl.callback")
local minimum_neovim_version = "0.9.0"
if vim then
  if (0 == _G.vim.fn.has(("nvim-" .. minimum_neovim_version))) then
    error(("nfnl requires Neovim > v" .. minimum_neovim_version))
  else
  end
  vim.api.nvim_create_autocmd({"Filetype"}, {group = vim.api.nvim_create_augroup("nfnl-setup", {}), pattern = "fennel", callback = callback["fennel-filetype-callback"]})
  if ("fennel" == vim.o.filetype) then
    callback["fennel-filetype-callback"]({file = vim.fn.expand("%"), buf = vim.api.nvim_get_current_buf()})
  else
  end
else
end
local function setup()
  return "A noop for now, may be used one day. You just need to load this module for the plugin to initialise for now."
end
return {setup = setup}
