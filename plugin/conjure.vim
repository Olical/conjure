autocmd FileType clojure nnoremap <localleader>rp :call conjure#list()<CR>
autocmd FileType clojure nnoremap <localleader>rl :call conjure#show_log()<CR>

autocmd FileType clojure nnoremap <localleader>rd :call
            \ conjure#doc("<C-r>=expand("<cword>")<CR>", "<C-r>=expand("%")<CR>")<CR>
