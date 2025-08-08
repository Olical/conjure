-- [nfnl] plugin/conjure.fnl
local minimum_version = "0.10"
if (1 == vim.fn.has(("nvim-" .. minimum_version))) then
  local main = require("conjure.main")
  return main.main()
else
  return vim.notify_once(("Conjure requires Neovim > v" .. minimum_version), vim.log.levels.ERROR)
end
