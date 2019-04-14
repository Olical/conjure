let s:jobid = -1
let s:cwd = resolve(expand("<sfile>:p:h") . "/..")

if $CONJURE_JOB_OPTS != ""
  let s:job_opts = $CONJURE_JOB_OPTS
else
  let s:job_opts = "-A:fast"
endif

" Create commands for RPC calls handled by main.clj.
command! -nargs=1 ConjureAdd call rpcnotify(s:jobid, "add", <q-args>)
command! -nargs=1 ConjureRemove call rpcnotify(s:jobid, "remove", <q-args>)
command! -nargs=0 ConjureRemoveAll call rpcnotify(s:jobid, "remove_all")
command! -nargs=0 ConjureStatus call rpcnotify(s:jobid, "status")

command! -nargs=1 ConjureEval call rpcnotify(s:jobid, "eval", <q-args>)
command! -range   ConjureEvalSelection call rpcnotify(s:jobid, "eval_selection")
command! -nargs=0 ConjureEvalCurrentForm call rpcnotify(s:jobid, "eval_current_form")
command! -nargs=0 ConjureEvalRootForm call rpcnotify(s:jobid, "eval_root_form")
command! -nargs=0 ConjureEvalBuffer call rpcnotify(s:jobid, "eval_buffer")
command! -nargs=1 ConjureLoadFile call rpcnotify(s:jobid, "load_file", <q-args>)

command! -nargs=1 ConjureDefinition call rpcnotify(s:jobid, "definition", <q-args>)
command! -nargs=1 ConjureDoc call rpcnotify(s:jobid, "doc", <q-args>)
command! -nargs=0 ConjureOpenLog call rpcnotify(s:jobid, "open_log")
command! -nargs=0 ConjureCloseLog call rpcnotify(s:jobid, "close_log")
command! -nargs=* ConjureRunTests call rpcnotify(s:jobid, "run_tests", <q-args>)
command! -nargs=? ConjureRunAllTests call rpcnotify(s:jobid, "run_all_tests", <q-args>)

" Default mappings if not disabled.
if !exists("g:conjure_default_mappings") || g:conjure_default_mappings
  augroup conjure
    autocmd!
    autocmd InsertEnter *.clj,*.clj[cs] :call conjure#close_unused_log()
    autocmd FileType clojure nnoremap <buffer> <localleader>re :ConjureEvalCurrentForm<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rr :ConjureEvalRootForm<cr>
    autocmd FileType clojure vnoremap <buffer> <localleader>re :ConjureEvalSelection<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rf :ConjureEvalBuffer<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rF :ConjureLoadFile <c-r>=expand('%:p')<cr><cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rs :ConjureStatus<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rl :ConjureOpenLog<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rq :ConjureCloseLog<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rt :ConjureRunTests<cr>
    autocmd FileType clojure nnoremap <buffer> <localleader>rT :ConjureRunAllTests<cr>
    autocmd FileType clojure nnoremap <buffer> K :ConjureDoc <c-r><c-w><cr>
    autocmd FileType clojure nnoremap <buffer> gd :ConjureDefinition <c-r><c-w><cr>
    autocmd FileType clojure setlocal omnifunc=conjure#omnicomplete
  augroup END
endif

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

" Reset the jobid then call start again.
function! conjure#on_exit(jobid, msg, event) dict
  if a:msg != 0
    echohl ErrorMsg
    echo "Conjure exited, restarting"
    echohl None

    let s:jobid = -1
    call conjure#start()
  endif
endfunction

" Start up the Clojure process if we haven't already.
function! conjure#start()
  if s:jobid == -1
    let s:jobid = jobstart("clojure " . s:job_opts . " -m conjure.main", {
    \  "rpc": v:true,
    \  "cwd": s:cwd,
    \  "on_stderr": "conjure#on_stderr",
    \  "on_exit": "conjure#on_exit"
    \})
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
    let line = getline('.')[0 : col('.')-2]
    return col('.') - strlen(matchstr(line, '\k\+$')) - 1
  else
    return conjure#completions(a:base)
  endif
endfunction

function! conjure#completions(base)
  return rpcrequest(s:jobid, "completions", a:base)
endfunction

function! conjure#get_rpc_port()
  return rpcrequest(s:jobid, "get_rpc_port")
endfunction

" Perform any required setup.
function! conjure#init()
  " Start the job if `make dev` isn't limiting the cwd.
  " This is useful because you can turn off your globally installed
  " version and override it with the development version temporarily.
  if $CONJURE_ALLOWED_DIR == "" || $CONJURE_ALLOWED_DIR == s:cwd
    call conjure#start()
  endif
endfunction
