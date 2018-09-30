function! s:OnEvent(job_id, data, event) dict
  if a:event == "stdout"
    " Look for any existing req_ids in this string
    " If we find one we extract the content and echo it
  elseif a:event == "stderr"
    echoerr 'Conjure: '.join(a:data)
  endif
endfunction

let s:term_opts = {
\ "on_stdout": function("s:OnEvent"),
\ "on_stderr": function("s:OnEvent")
\ }

function! conjure#connect()
  new
  let s:repl_term_id = termopen("rlwrap nc localhost 9045", s:term_opts)
  let s:reqs = {}
  let s:req_id = 0
  normal! G
endfunction

function! conjure#eval(type)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:0
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == "line"
    silent exe "normal! '[V']y"
  elseif a:type == "block"
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif

  call jobsend(s:repl_term_id, @@ . "\n")

  let &selection = sel_save
  let @@ = reg_save
endfunction
