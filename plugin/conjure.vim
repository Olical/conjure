function! s:OnStderr(jobid, lines, source) dict
  echohl ErrorMsg
  for line in a:lines
    if len(line) > 0
      echomsg line
    endif
  endfor
  echo "Error from Conjure, see :messages for more"
  echohl None
endfunction

if ! exists("s:jobid")
  let s:jobid = jobstart("clojure -m conjure.main", {
  \  "rpc": v:true,
  \  "cwd": resolve(expand("<sfile>:p:h") . "/.."),
  \  "on_stderr": function("s:OnStderr")
  \})
endif

command! -nargs=1 DevAdd call rpcnotify(s:jobid, "add", <q-args>)
command! -nargs=1 DevRemove call rpcnotify(s:jobid, "remove", <q-args>)
