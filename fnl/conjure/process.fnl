(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local str (autoload :conjure.aniseed.string))

;; For the execution of external processes through Neovim's terminal
;; integration. This module only cares about checking for some required program
;; and then executing it with some arguments in a terminal buffer. It doesn't
;; manage the lifecycle past that point, so it's very much on it's own after it
;; begins.
;;
;; The initial use case for this is to start a babashka REPL for Clojure files
;; if no nREPL connection can be established.

(fn executable? [cmd]
  "Check if the given program name can be found on the system. If you give it a
  full command with arguments it'll just check the first word."
  (= 1 (nvim.fn.executable (a.first (str.split cmd "%s+")))))

(fn running? [proc]
  (if proc
    (. proc :running?)
    false))

(local state {:jobs {}})

(fn on-exit [job-id]
  (let [proc (. state.jobs job-id)]
    (when (running? proc)
      (a.assoc proc :running? false)
      (tset state.jobs proc.job-id nil)
      (pcall nvim.buf_delete proc.buf {:force true})
      (let [on-exit (a.get-in proc [:opts :on-exit])]
        (when on-exit
          (on-exit proc))))))

;; TODO When Neovim 0.5 is stable we can pass a Lua function across this
;; boundary. Until then, yucky gross stuff.
;; This is absolutely horrible, but there's no other way to do it if I want to
;; support anything < 0.5 for now.
;; So rather than just using a closure to pass the proc into the exit fn, I
;; have to go through a VimL function that relies on a global table of jobs to
;; look the data back up.
(nvim.ex.function_
  (str.join
    "\n"
    ["ConjureProcessOnExit(...)"
     "call luaeval(\"require('conjure.process')['on-exit'](unpack(_A))\", a:000)"
     "endfunction"]))

(fn execute [cmd opts]
  (let [win (nvim.tabpage_get_win 0)
        original-buf (nvim.win_get_buf win)
        term-buf (nvim.create_buf (not (?. opts :hidden?)) true)
        proc {:cmd cmd :buf term-buf
              :running? true
              :opts opts}
        job-id (do
                 (nvim.win_set_buf win term-buf)
                 (nvim.fn.termopen cmd {:on_exit "ConjureProcessOnExit"}))]
    (match job-id
      0 (error "invalid arguments or job table full")
      -1 (error (.. "'" cmd "' is not executable")))
    (nvim.win_set_buf win original-buf)
    (tset state.jobs job-id proc)
    (a.assoc proc :job-id job-id)))

(fn stop [proc]
  (when (running? proc)
    (nvim.fn.jobstop proc.job-id)
    (on-exit proc.job-id))
  proc)

{
 : executable?
 : running?
 : on-exit
 : execute
 : stop
 }
