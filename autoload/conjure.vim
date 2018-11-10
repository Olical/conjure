if ! exists('s:jobid')
  let s:jobid = 0
endif

let s:scriptdir = resolve(expand('<sfile>:p:h') . '/..')
let s:bin = s:scriptdir . '/target/debug/conjure'

function! conjure#list()
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, 'list')
  endif
endfunction

function! conjure#connect(key, addr, expr)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, 'connect', a:key, a:addr, a:expr)
  endif
endfunction

function! conjure#disconnect(key)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, 'disconnect', a:key)
  endif
endfunction

function! conjure#eval(code, path)
  if conjure#upsert_job() == 0
    call rpcnotify(s:jobid, 'eval', a:code, a:path)
  endif
endfunction

function! conjure#upsert_job()
  if s:jobid == 0
    let id = jobstart([s:bin], {
          \ 'rpc': v:true,
          \ 'on_stderr': function('s:OnStderr'),
          \ 'on_exit': function('s:OnExit')
          \ })

    if id == -1
      echoerr "conjure: failed to start job"
      return -1
    else
      let s:jobid = id

      augroup conjure
        autocmd!
        autocmd VimLeavePre * :call s:StopJob()
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

    call rpcnotify(s:jobid, 'exit')
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
    echoerr 'conjure: ' . a:id . ' ' . a:event . ' ' . join(a:data, "\n")
  endif
endfunction

function! s:OnExit(id, data, event) dict
  let s:jobid = 0
endfunction
