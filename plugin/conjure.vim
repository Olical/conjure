if has("nvim-0.4")
  let &runtimepath .= ',' . escape(expand('<sfile>:p:h:h'), '\,')
  lua require("conjure.main").main()
else
  echoerr "Conjure requires Neovim > v0.4"
endif
