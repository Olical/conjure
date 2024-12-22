if vim.fn.has("nvim-0.8") == 1 then
  require("conjure.main").main()
else
  vim.notify_once("Conjure requires Neovim > v0.8", vim.log.levels.ERROR)
end
