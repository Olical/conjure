if ! exists('s:jobid')
  let s:jobid = 0
endif

let s:scriptdir = resolve(expand('<sfile>:p:h') . '/..')
let s:bin = s:scriptdir . '/target/release/conjure'

function! conjure#connect(addr)
  if s:UpsertJob() == 0
    return rpcrequest(s:jobid, 'connect', a:addr)
  endif
endfunction

function! s:UpsertJob()
  if s:jobid == 0
    let id = jobstart([s:bin], { 'rpc': v:true, 'on_stderr': function('s:OnStderr') })

    if id == -1
      echoerr "conjure: failed to start job"
      return 1
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

function! s:OnStderr(id, data, event) dict
  echoerr 'conjure: ' . a:id . ' ' . a:event . ' ' . join(a:data, "\n")
endfunction

function! s:StopJob()
  if s:jobid != 0
    augroup conjure
      autocmd!
    augroup END

    call rpcnotify(s:jobid, 'quit')
    let result = jobwait([s:jobid], 500)

    if result == [-1]
      call jobstop(s:jobid)
    endif

    let s:jobid = 0
  endif
endfunction
