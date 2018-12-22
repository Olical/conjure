if ! exists("s:jobid")
  let s:jobid = 0
endif

let s:scriptdir = resolve(expand("<sfile>:p:h") . "/..")
let s:bin = s:scriptdir . "/target/debug/conjure"

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

function! conjure#eval(code, path)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "eval", a:code, a:path)
  endif
endfunction

function! conjure#eval_with_out_str(code, path)
  call conjure#eval(printf('
        \(let [result! (atom nil)]
        \  (println
        \    (with-out-str
        \      (reset! result! (do %s))))
        \  @result!)
        \', a:code), a:path)
endfunction

function! conjure#doc(name, path)
  call conjure#eval_with_out_str(printf('(#?(:clj clojure.repl/doc, :cljs cljs.repl/doc) %s)', a:name), a:path)
endfunction

function! conjure#go_to_definition(name, path)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, "go_to_definition", a:name, a:path)
  endif
endfunction

function! conjure#load_file(path)
  call conjure#eval(printf('(clojure.core/load-file "%s")', a:path), a:path)
endfunction

function! conjure#run_tests(path)
  call conjure#load_file(a:path)
  call conjure#eval_with_out_str('
        \#?(:clj (binding [clojure.test/*test-out* *out*] (clojure.test/run-tests))
        \   :cljs (cljs.test/run-tests))', a:path)
endfunction

function! conjure#run_all_tests(path)
  call conjure#load_file(a:path)
  call conjure#eval_with_out_str('
        \#?(:clj (binding [clojure.test/*test-out* *out*] (clojure.test/run-all-tests))
        \   :cljs (cljs.test/run-all-tests))
        \', a:path)
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
