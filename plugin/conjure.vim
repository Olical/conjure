" Copied from http://vim.wikia.com/wiki/Act_on_text_objects_with_custom_functions
" Adapted from tpope/vim-unimpaired
function! s:DoAction(algorithm,type)
  " backup settings that we will change
  let sel_save = &selection
  let cb_save = &clipboard
  " make selection and clipboard work the way we need
  set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
  " backup the unnamed register, which we will be yanking into
  let reg_save = @@
  " yank the relevant text, and also set the visual selection (which will be reused if the text
  " needs to be replaced)
  if a:type =~ '^\d\+$'
    " if type is a number, then select that many lines
    silent exe 'normal! V'.a:type.'$y'
  elseif a:type =~ '^.$'
    " if type is 'v', 'V', or '<C-V>' (i.e. 0x16) then reselect the visual region
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    " line-based text motion
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    " block-based text motion
    silent exe "normal! `[\<C-V>`]y"
  else
    " char-based text motion
    silent exe "normal! `[v`]y"
  endif
  " call the user-defined function, passing it the contents of the unnamed register
  let repl = s:{a:algorithm}(@@)
  " if the function returned a value, then replace the text
  if type(repl) == 1
    " put the replacement text into the unnamed register, and also set it to be a
    " characterwise, linewise, or blockwise selection, based upon the selection type of the
    " yank we did above
    call setreg('@', repl, getregtype('@'))
    " relect the visual region and paste
    normal! gvp
  endif
  " restore saved settings and register value
  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save
endfunction

function! s:ActionOpfunc(type)
  return s:DoAction(s:encode_algorithm, a:type)
endfunction

function! s:ActionSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'ActionOpfunc'
endfunction

function! s:MapAction(algorithm, key)
  exe 'nnoremap <buffer> <Plug>actions'.a:algorithm.' :<C-U>call <SID>ActionSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap <buffer> <Plug>actions'.a:algorithm.' :<C-U>call <SID>DoAction("'.a:algorithm.'",visualmode())<CR>'
  exe 'nnoremap <buffer> <Plug>actionsLine'.a:algorithm.' :<C-U>call <SID>DoAction("'.a:algorithm.'",v:count1)<CR>'
  exe 'nmap <buffer> '.a:key.' <Plug>actions'.a:algorithm
  exe 'xmap <buffer> '.a:key.' <Plug>actions'.a:algorithm
  exe 'nmap <buffer> '.a:key.a:key[strlen(a:key)-1].' <Plug>actionsLine'.a:algorithm
endfunction

function! s:Eval(str)
  call conjure#eval(a:str)
endfunction

let g:conjure_refresh_dirs = ["src"]
let g:conjure_refresh_after = ":noop"

augroup conjure_bindings
  autocmd!
  autocmd FileType clojure nnoremap <buffer> <localleader>rp :call conjure#list()<cr>
  autocmd FileType clojure nnoremap <buffer> <localleader>rl :call conjure#show_log()<cr>

  autocmd FileType clojure call s:MapAction('Eval', 'cp')
  autocmd FileType clojure nnoremap <buffer> cpp :normal mscpaf<cr>`s
  autocmd FileType clojure nnoremap <buffer> <localleader>re :normal mscpaF<cr>`s

  autocmd FileType clojure nnoremap <buffer> <localleader>rf :call conjure#eval_file()<cr>
  autocmd FileType clojure nnoremap <buffer> <localleader>rb :call conjure#eval_buffer()<cr>

  autocmd FileType clojure nnoremap <buffer> <localleader>rt :call conjure#run_tests()<cr>
  autocmd FileType clojure nnoremap <buffer> <localleader>rT :call conjure#run_all_tests()<cr>

  autocmd FileType clojure nnoremap <buffer> <localleader>rr :call conjure#refresh()<cr>
  autocmd FileType clojure nnoremap <buffer> <localleader>rR :call conjure#refresh_all()<cr>

  autocmd FileType clojure nnoremap <buffer> K :call conjure#doc(expand('<cword>'))<cr>
  autocmd FileType clojure nnoremap <buffer> gd :call conjure#go_to_definition(expand('<cword>'))<cr>

  autocmd FileType clojure setlocal omnifunc=conjure#omnicomplete
  autocmd CursorHold * if &ft ==# 'clojure' | call conjure#update_completions()
augroup END
