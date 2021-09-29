if has("nvim-0.5")
  lua require("conjure.main").main()
else
  echoerr "Conjure requires Neovim > v0.5"
endif
