function! s:OnStderr(jobid, lines, source) dict
  echohl ErrorMsg
  for line in a:lines
    if len(line) > 0
      echomsg line
    endif
  endfor
  echomsg "Error from Conjure, see :messages for more."
  echohl None
endfunction

if ! exists("s:jobid")
  let s:jobid = jobstart("clojure -m conjure.main", {
  \  "rpc": v:true,
  \  "cwd": resolve(expand("<sfile>:p:h") . "/.."),
  \  "on_stderr": function("s:OnStderr")
  \})
endif

command! -nargs=0 ConjurePing echo rpcnotify(s:jobid, "ping", "<3")
