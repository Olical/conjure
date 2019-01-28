if ! exists("s:jobid")
  let s:jobid = 0
endif

let s:scriptdir = resolve(expand("<sfile>:p:h") . "/..")
let s:bin = s:scriptdir . "/target/debug/conjure"

func! conjure#prev_cword()
  let [clnum, ccol] = searchpos('\<\k*\%(\k\@!.\)*\%#', 'bcWn')
  if ccol >= 1
    return matchstr(strpart(getline(clnum), ccol-1), '^\k*')
  else
    return ""
  endif
endfunc

function! conjure#list()
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "list")
  endif
endfunction

function! conjure#show_log()
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "show_log")
  endif
endfunction

function! conjure#connect(key, addr, expr, lang)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "connect", a:key, a:addr, a:expr, a:lang)
  endif
endfunction

function! conjure#disconnect(key)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "disconnect", a:key)
  endif
endfunction

function! conjure#eval(code)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "eval", a:code)
  endif
endfunction

function! conjure#eval_with_out_str(code)
  call conjure#eval(printf("
        \(let [result! (atom nil)]
        \  (println
        \    (with-out-str
        \      (reset! result! (do %s))))
        \  @result!)
        \", a:code))
endfunction

function! conjure#doc(name)
  call conjure#eval_with_out_str(printf("(#?(:clj clojure.repl/doc, :cljs cljs.repl/doc) %s)", a:name))
endfunction

function! conjure#go_to_definition(name)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "go_to_definition", a:name)
  endif
endfunction

function! conjure#omnicomplete(findstart, base)
  if exists("b:conjure_completions")
    if a:findstart
      let line = getline('.')[0 : col('.')-2]
      return col('.') - strlen(matchstr(line, '\k\+$')) - 1
    else
      return filter(copy(b:conjure_completions), 'a:base ==# "" || a:base ==# v:val[0 : strlen(a:base)-1]')
    endif
  else
    return -2
  endif
endfunction

function! conjure#update_completions()
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "update_completions")
  endif
endfunction

function! conjure#eval_file()
  call conjure#eval(printf('(clojure.core/load-file "%s")', expand("%")))
endfunction

function! conjure#eval_buffer()
  call conjure#eval(join(getline(1, '$'), "\n"))
endfunction

function! conjure#run_tests()
  call conjure#eval_file()
  call conjure#eval_with_out_str("
        \#?(:clj (binding [clojure.test/*test-out* *out*] (clojure.test/run-tests))
        \   :cljs (cljs.test/run-tests))")
endfunction

function! conjure#run_all_tests()
  call conjure#eval_file()
  call conjure#eval_with_out_str("
        \#?(:clj (binding [clojure.test/*test-out* *out*] (clojure.test/run-all-tests))
        \   :cljs (cljs.test/run-all-tests))
        \")
endfunction

function! conjure#upsert_job()
  if s:jobid == 0
    let id = jobstart([s:bin], {
          \ "rpc": v:true,
          \ "on_stderr": function("s:OnStderr"),
          \ "on_exit": function("s:OnExit")
          \ })

    if id == -1
      echoerr "conjure: failed to start job"
      return -1
    else
      let s:jobid = id

      augroup conjure
        autocmd!
        autocmd VimLeavePre * :call conjure#stop_job()
      augroup END
    endif
  endif

  return 0
endfunction

function! conjure#stop_job()
  if s:jobid != 0
    augroup conjure
      autocmd!
    augroup END

    call rpcnotify(s:jobid, "exit")
    let result = jobwait([s:jobid], 500)

    if result == [-1]
      call jobstop(s:jobid)
    endif
  endif
endfunction

function! conjure#restart_job()
  call conjure#stop_job()
  call conjure#upsert_job()
endfunction

function! s:OnStderr(id, data, event) dict
  if len(a:data) > 0 && len(a:data[0]) > 0
    echoerr "conjure: " . a:id . " " . a:event . " " . join(a:data, "\n")
  endif
endfunction

function! s:OnExit(id, data, event) dict
  let s:jobid = 0
endfunction
