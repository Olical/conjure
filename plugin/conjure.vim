if has("nvim-0.4")
  let s:path = escape(expand('<sfile>:h:h'), '\,')
  echo s:path
  if stridx(&runtimepath, s:path) == -1
    let &runtimepath .= ',' . s:path
  endif

  lua require("conjure.main").main()
else
  echoerr "Conjure requires Neovim > v0.4"
endif
