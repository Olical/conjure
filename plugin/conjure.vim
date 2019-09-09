let s:cwd = resolve(expand("<sfile>:p:h") . "/..")

" Don't load if...
"  * Not in Neovim
"  * Already loaded
"  * Blocked by CONJURE_ALLOWED_DIR (bin/dev)
if !has('nvim') || exists("g:conjure_loaded") || ($CONJURE_ALLOWED_DIR != "" && $CONJURE_ALLOWED_DIR != s:cwd)
  finish
endif

let g:conjure_loaded = v:true
let g:conjure_initialised = v:false
let g:conjure_ready = v:false

" Helpers to remove boilerplate code.
function! s:def_config(name, default)
  execute "let g:conjure_" . a:name . " = get(g:, 'conjure_" . a:name . "', " . string(a:default) . ")"
endfunction

function! s:def_map(mode, config_name, cmd)
  let l:keys = get(g:, "conjure_" . a:mode . "map_" . a:config_name)

  if l:keys != v:null
    execute "autocmd FileType clojure " . a:mode . "noremap <silent> <buffer> " . l:keys . " " . a:cmd . "<cr>"
  endif
endfunction

" User config with defaults.
call s:def_config("log_direction", "vertical") " vertical/horizontal
call s:def_config("log_size_small", 25) " %
call s:def_config("log_size_large", 50) " %
call s:def_config("log_auto_close", v:true) " boolean
call s:def_config("log_blacklist", []) " set
call s:def_config("fold_results", v:false) " boolean
call s:def_config("quick_doc_normal_mode", v:true) " boolean
call s:def_config("quick_doc_insert_mode", v:true) " boolean
call s:def_config("quick_doc_time", 250) " ms
call s:def_config("omnifunc", v:true) " boolean
call s:def_config("default_mappings", v:true) " boolean

let s:jobid = v:null
let s:dev = $CONJURE_ALLOWED_DIR != ""

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
command! -nargs=0 ConjureQuickDoc call conjure#quick_doc()
command! -nargs=0 ConjureClearVirtual call conjure#notify("clear_virtual")
command! -nargs=0 ConjureOpenLog call conjure#notify("open_log")
command! -nargs=0 ConjureCloseLog call conjure#notify("close_log")
command! -nargs=0 ConjureToggleLog call conjure#notify("toggle_log")
command! -nargs=* ConjureRunTests call conjure#notify("run_tests", <q-args>)
command! -nargs=? ConjureRunAllTests call conjure#notify("run_all_tests", <q-args>)
command! -nargs=* ConjureRefresh call conjure#notify("refresh", <q-args>)

augroup conjure
  autocmd!
  autocmd BufEnter *.clj,*.clj[cs] call conjure#init()
  autocmd VimLeavePre * call conjure#stop()

  if g:conjure_default_mappings
    call s:def_config("map_prefix", "<localleader>")
    call s:def_config("nmap_eval_word", g:conjure_map_prefix . "ew")
    call s:def_config("nmap_eval_current_form", g:conjure_map_prefix . "ee")
    call s:def_config("nmap_eval_root_form", g:conjure_map_prefix . "er")
    call s:def_config("vmap_eval_selection", g:conjure_map_prefix . "ee")
    call s:def_config("nmap_eval_buffer", g:conjure_map_prefix . "eb")
    call s:def_config("nmap_eval_file", g:conjure_map_prefix . "ef")
    call s:def_config("nmap_up", g:conjure_map_prefix . "cu")
    call s:def_config("nmap_status", g:conjure_map_prefix . "cs")
    call s:def_config("nmap_open_log", g:conjure_map_prefix . "cl")
    call s:def_config("nmap_close_log", g:conjure_map_prefix . "cq")
    call s:def_config("nmap_toggle_log", g:conjure_map_prefix . "cL")
    call s:def_config("nmap_run_tests", g:conjure_map_prefix . "tt")
    call s:def_config("nmap_run_all_tests", g:conjure_map_prefix . "ta")
    call s:def_config("nmap_refresh_changed", g:conjure_map_prefix . "rr")
    call s:def_config("nmap_refresh_all", g:conjure_map_prefix . "rR")
    call s:def_config("nmap_refresh_clear", g:conjure_map_prefix . "rc")
    call s:def_config("nmap_doc", "K")
    call s:def_config("nmap_definition", "gd")

    call s:def_map("n", "eval_word", ":ConjureEval <c-r><c-w>")
    call s:def_map("n", "eval_current_form", ":ConjureEvalCurrentForm")
    call s:def_map("n", "eval_root_form", ":ConjureEvalRootForm")
    call s:def_map("v", "eval_selection", ":ConjureEvalSelection")
    call s:def_map("n", "eval_buffer", ":ConjureEvalBuffer")
    call s:def_map("n", "eval_file", ":ConjureLoadFile <c-r>=expand('%')<cr>")

    call s:def_map("n", "up", ":ConjureUp")
    call s:def_map("n", "status", ":ConjureStatus")
    call s:def_map("n", "open_log", ":ConjureOpenLog")
    call s:def_map("n", "close_log", ":ConjureCloseLog")
    call s:def_map("n", "toggle_log", ":ConjureToggleLog")

    call s:def_map("n", "run_tests", ":ConjureRunTests")
    call s:def_map("n", "run_all_tests", ":ConjureRunAllTests")

    call s:def_map("n", "refresh_changed", ":ConjureRefresh changed")
    call s:def_map("n", "refresh_all", ":ConjureRefresh all")
    call s:def_map("n", "refresh_clear", ":ConjureRefresh clear")

    call s:def_map("n", "doc", ":ConjureDoc <c-r><c-w>")
    call s:def_map("n", "definition", ":ConjureDefinition <c-r><c-w>")
  endif

  if g:conjure_log_auto_close
    autocmd InsertEnter *.edn,*.clj,*.clj[cs] :call conjure#close_unused_log()
  endif

  if g:conjure_quick_doc_normal_mode
    autocmd CursorMoved *.edn,*.clj,*.clj[cs] :call conjure#quick_doc()

    if !g:conjure_quick_doc_insert_mode
      autocmd InsertEnter *.edn,*.clj,*.clj[cs] :ConjureClearVirtual
    endif
  endif

  if g:conjure_quick_doc_insert_mode
    autocmd CursorMovedI *.edn,*.clj,*.clj[cs] :call conjure#quick_doc()

    if !g:conjure_quick_doc_normal_mode
      autocmd InsertEnter *.edn,*.clj,*.clj[cs] :call conjure#quick_doc()
      autocmd InsertLeave *.edn,*.clj,*.clj[cs] :ConjureClearVirtual
    endif
  endif

  if g:conjure_quick_doc_normal_mode || g:conjure_quick_doc_insert_mode
    autocmd BufLeave *.edn,*.clj,*.clj[cs] :call conjure#quick_doc_cancel()
  endif

  if !g:conjure_quick_doc_normal_mode && !g:conjure_quick_doc_insert_mode
    autocmd CursorMoved *.edn,*.clj,*.clj[cs] :ConjureClearVirtual
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

    let s:jobid = v:null
    let g:conjure_ready = v:false
  endif
endfunction

" Start up the Clojure process if we haven't already.
function! conjure#start()
  if s:jobid == v:null
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
  if s:jobid != v:null
    call conjure#notify("stop")
  endif
endfunction

" Trigger quick doc on CursorMoved(I) with a debounce.
" It displays the doc for the head of the current form using virtual text.
let s:quick_doc_timer = v:null

function! conjure#quick_doc_cancel()
  if s:quick_doc_timer != v:null
    call timer_stop(s:quick_doc_timer)
    let s:quick_doc_timer = v:null
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
  if s:jobid != v:null
    call conjure#quick_doc_cancel()
    return rpcnotify(s:jobid, a:method, get(a:, 1, 0))
  endif
endfunction

function! conjure#request(method, ...)
  if s:jobid != v:null
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

" Handle omnicomplete requests through compliment if it's there.
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
    return v:true
  else
    let l:name = synIDattr(l:stack[-1], "name")

    " If it's comment or string we're not in code.
    return !(l:name ==# "clojureComment" || l:name ==# "clojureString")
  endif
endfunction

" Is Conjure ready and are we typing in some code.
" Then the autocompletion plugins should kick in.
function! conjure#should_autocomplete()
  return g:conjure_ready && conjure#cursor_in_code()
endfunction

" Initialise if not done already.
function! conjure#init()
  if g:conjure_initialised == v:false
    if s:dev || filereadable(s:cwd . "/classes/conjure/main$_main.class")
      let g:conjure_initialised = v:true
      call conjure#start()
      ConjureUp
    else
      echomsg "Conjure not compiled, please run bin/compile then conjure#init() or restart"
    endif
  endif
endfunction
