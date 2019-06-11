let s:cwd = resolve(expand("<sfile>:p:h") . "/..")

" Don't load if...
"  * Not in Neovim
"  * Already loaded
"  * Blocked by CONJURE_ALLOWED_DIR (bin/dev)
if !has('nvim') || exists("g:conjure_loaded") || ($CONJURE_ALLOWED_DIR != "" && $CONJURE_ALLOWED_DIR != s:cwd)
  finish
endif

let g:conjure_loaded = 1
let g:conjure_initialised = 0
let g:conjure_ready = 0

" User config with defaults.
let g:conjure_default_mappings = get(g:, 'conjure_default_mappings', 1) " 1/0
let g:conjure_log_direction = get(g:, 'conjure_log_direction', "vertical") " vertical/horizontal
let g:conjure_log_size_small = get(g:, 'conjure_log_size_small', 25) " %
let g:conjure_log_size_large = get(g:, 'conjure_log_size_large', 50) " %
let g:conjure_log_auto_close = get(g:, 'conjure_log_auto_close', 1) " 1/0
let g:conjure_log_auto_open = get(g:, 'conjure_log_auto_open', "multiline") " always/multiline/never
let g:conjure_fold_results = get(g:, 'conjure_fold_multiline_results', 0) " 1/0
let g:conjure_quick_doc_normal_mode = get(g:, 'conjure_quick_doc_normal_mode', 1) " 1/0
let g:conjure_quick_doc_insert_mode = get(g:, 'conjure_quick_doc_insert_mode', 1) " 1/0
let g:conjure_quick_doc_time = get(g:, 'conjure_quick_doc_time', 250) " ms
let g:conjure_omnifunc = get(g:, 'conjure_omnifunc', 1) " 1/0

let s:jobid = -1

if $CONJURE_JOB_OPTS != ""
  let s:job_opts = $CONJURE_JOB_OPTS
else
  let s:job_opts = "-A:fast"
endif

" Create commands for RPC calls handled by main.clj.
command! -nargs=* ConjureUp call conjure#notify("up", <q-args>)
command! -nargs=0 ConjureStatus call conjure#notify("status")

command! -nargs=1 ConjureEval call conjure#notify("eval", <q-args>)
command! -range   ConjureEvalSelection call conjure#notify("eval_selection")
command! -nargs=0 ConjureEvalCurrentForm call conjure#notify("eval_current_form")
command! -nargs=0 ConjureEvalRootForm call conjure#notify("eval_root_form")
command! -nargs=0 ConjureEvalBuffer call conjure#notify("eval_buffer")
command! -nargs=1 ConjureLoadFile call conjure#notify("load_file", <q-args>)

command! -nargs=1 ConjureDefinition call conjure#notify("definition", <q-args>)
command! -nargs=1 ConjureDoc call conjure#notify("doc", <q-args>)
command! -nargs=1 ConjureQuickDoc call conjure#quick_doc()
command! -nargs=0 ConjureOpenLog call conjure#notify("open_log")
command! -nargs=0 ConjureCloseLog call conjure#notify("close_log")
command! -nargs=* ConjureRunTests call conjure#notify("run_tests", <q-args>)
command! -nargs=? ConjureRunAllTests call conjure#notify("run_all_tests", <q-args>)

augroup conjure
  autocmd!
  autocmd BufEnter *.clj,*.clj[cs] call conjure#init()
  autocmd VimLeavePre * call conjure#stop()

  if g:conjure_default_mappings
    autocmd FileType clojure nnoremap <buffer> <localleader>ee :ConjureEvalCurrentForm<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>er :ConjureEvalRootForm<cr>
    autocmd FileType clojure vnoremap <buffer> <localleader>ee :ConjureEvalSelection<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>eb :ConjureEvalBuffer<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>ef :ConjureLoadFile <c-r>=expand('%:p')<cr><cr>

    autocmd FileType clojure nnoremap <buffer> <localleader>cu :ConjureUp<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>cs :ConjureStatus<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>cl :ConjureOpenLog<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>cq :ConjureCloseLog<cr>

    autocmd FileType clojure nnoremap <buffer> <localleader>tt :ConjureRunTests<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>ta :ConjureRunAllTests<cr>

    autocmd FileType clojure nnoremap <buffer> K :ConjureDoc <c-r><c-w><cr>
    autocmd FileType clojure nnoremap <buffer> gd :ConjureDefinition <c-r><c-w><cr>
  endif

  if g:conjure_log_auto_close
    autocmd InsertEnter *.edn,*.clj,*.clj[cs] :call conjure#close_unused_log()
  endif

  if g:conjure_quick_doc_normal_mode
    autocmd CursorMoved *.edn,*.clj,*.clj[cs] :call conjure#quick_doc()
  endif

  if g:conjure_quick_doc_insert_mode
    autocmd CursorMovedI *.edn,*.clj,*.clj[cs] :call conjure#quick_doc()
  endif

  if g:conjure_quick_doc_normal_mode || g:conjure_quick_doc_insert_mode
    autocmd BufLeave *.edn,*.clj,*.clj[cs] :call conjure#quick_doc_cancel()
  endif

  if g:conjure_omnifunc
    autocmd FileType clojure setlocal omnifunc=conjure#omnicomplete
  endif
augroup END

" Handles all stderr from the Clojure process.
" Simply prints it in red.
function! conjure#on_stderr(jobid, lines, event) dict
  echohl ErrorMsg
  for line in a:lines
    if len(line) > 0
      echomsg line
    endif
  endfor
  echo "Error from Conjure, see :messages for more"
  echohl None
endfunction

" Reset the jobid, notify that you can restart easily.
function! conjure#on_exit(jobid, msg, event) dict
  if a:msg != 0
    echohl ErrorMsg
    echo "Conjure exited (" . a:msg . "), consider conjure#start()"
    echohl None

    let s:jobid = -1
    let g:conjure_ready = 0
  endif
endfunction

" Start up the Clojure process if we haven't already.
function! conjure#start()
  if s:jobid == -1
    let s:jobid = jobstart("clojure " . s:job_opts . " -m conjure.main " . getcwd(0), {
    \  "rpc": v:true,
    \  "cwd": s:cwd,
    \  "on_stderr": "conjure#on_stderr",
    \  "on_exit": "conjure#on_exit"
    \})
  endif
endfunction

" Stop the Clojure process if it's running.
function! conjure#stop()
  if s:jobid != -1
    call conjure#notify("stop")
  endif
endfunction

" Trigger quick doc on CursorMoved(I) with a debounce.
" It displays the doc for the head of the current form using virtual text.
let s:quick_doc_timer = -1

function! conjure#quick_doc_cancel()
  if s:quick_doc_timer != -1
    call timer_stop(s:quick_doc_timer)
    let s:quick_doc_timer = -1
  endif
endfunction

function! conjure#quick_doc()
  if g:conjure_ready
    call conjure#quick_doc_cancel()
    let s:quick_doc_timer = timer_start(g:conjure_quick_doc_time, {-> conjure#notify("quick_doc")})
  endif
endfunction

" Cancel existing quick doc timers and notify/request Conjure over RPC.
function! conjure#notify(method, ...)
  if s:jobid != -1
    call conjure#quick_doc_cancel()
    return rpcnotify(s:jobid, a:method, get(a:, 1, 0))
  endif
endfunction

function! conjure#request(method, ...)
  if s:jobid != -1
    call conjure#quick_doc_cancel()
    return rpcrequest(s:jobid, a:method, get(a:, 1, 0))
  endif
endfunction

" Close the log if we're not currently using it.
function! conjure#close_unused_log()
  if expand("%:p") !~# "/tmp/conjure.cljc"
    ConjureCloseLog
  endif
endfunction

" Handle omnicomplete requests through complement if it's there.
function! conjure#omnicomplete(findstart, base)
  if a:findstart
    let l:line = getline('.')[0 : col('.')-2]
    return col('.') - strlen(matchstr(l:line, '\k\+$')) - 1
  else
    return conjure#completions(a:base)
  endif
endfunction

function! conjure#completions(base)
  return conjure#request("completions", a:base)
endfunction

function! conjure#get_rpc_port()
  return conjure#request("get_rpc_port")
endfunction

" Is the cursor inside code or is it in a comment / string.
function! conjure#cursor_in_code()
  " Get the name of the syntax at the bottom of the stack.
  let l:stack = synstack(line("."), col("."))

  if len(l:stack) == 0
    return 1
  else
    let l:name = synIDattr(l:stack[-1], "name")

    " If it's comment or string we're not in code.
    return l:name ==# "clojureComment" || l:name ==# "clojureString" ? 0 : 1
  endif
endfunction

" Is Conjure ready and are we typing in some code.
" Then the autocompletion plugins should kick in.
function! conjure#should_autocomplete()
  return g:conjure_ready && conjure#cursor_in_code()
endfunction

" Initialise if not done already.
function! conjure#init()
  if g:conjure_initialised == 0
    let g:conjure_initialised = 1
    call conjure#start()
    ConjureUp
  endif
endfunction
