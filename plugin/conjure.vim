let s:cwd = resolve(expand("<sfile>:p:h") . "/..")

" Don't init if we're in `make dev` and not the dev dir.
" This is useful because you can turn off your globally installed
" version and override it with the development version temporarily.
if $CONJURE_ALLOWED_DIR == "" || $CONJURE_ALLOWED_DIR == s:cwd
  call conjure#init()
endif
