if has("nvim-0.7")
  lua require("conjure.main").main()
else
  echoerr "Conjure requires Neovim > v0.7"
endif
