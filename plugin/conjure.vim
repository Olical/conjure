command! ConjureConnect call conjure#connect()

autocmd FileType clojure nnoremap <buffer> cp :set opfunc=conjure#eval<cr>g@
autocmd FileType clojure nnoremap <buffer> cpp :normal cpaf<cr>
