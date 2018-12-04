autocmd FileType clojure nnoremap <localleader>rp :call conjure#list()<cr>
autocmd FileType clojure nnoremap <localleader>rl :call conjure#show_log()<cr>
autocmd FileType clojure nnoremap <localleader>rd :call conjure#doc(expand("<cword>"), expand("%"))<cr>
