-- [nfnl] plugin/conjure.fnl
if (1 == vim.fn.has("nvim-0.8")) then
  local main = require("conjure.main")
  return main.main()
else
  return vim.notify_once("Conjure requires Neovim > v0.8", vim.log.levels.ERROR)
end
