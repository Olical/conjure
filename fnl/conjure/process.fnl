(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.process))

;; For the execution of external processes through Neovim's terminal
;; integration. This module only cares about checking for some required program
;; and then executing it with some arguments in a terminal buffer. It doesn't
;; manage the lifecycle past that point, so it's very much on it's own after it
;; begins.
;;
;; The initial use case for this is to start a babashka REPL for Clojure files
;; if no nREPL connection can be established.

(fn M.executable? [cmd]
  "Check if the given program name can be found on the system. If you give it a
  full command with arguments it'll just check the first word."
  (= 1 (vim.fn.executable (core.first (str.split cmd "%s+")))))

(fn M.running? [proc]
  (if proc
    (. proc :running?)
    false))

(local state {:jobs {}})

(fn M.on-exit [job-id]
  (let [proc (. state.jobs job-id)]
    (when (M.running? proc)
      (core.assoc proc :running? false)
      (tset state.jobs proc.job-id nil)
      (pcall vim.api.nvim_buf_delete proc.buf {:force true})
      (let [on-exit (core.get-in proc [:opts :on-exit])]
        (when on-exit
          (on-exit proc))))))

(vim.api.nvim_create_user_command
  :ConjureProcessOnExit
  #(M.on-exit (. $ :args))
  {})

(fn M.execute [cmd opts]
  (let [win (vim.api.nvim_tabpage_get_win 0)
        original-buf (vim.api.nvim_win_get_buf win)
        term-buf (vim.api.nvim_create_buf (not (?. opts :hidden?)) true)
        proc {:cmd cmd :buf term-buf
              :running? true
              :opts opts}
        job-id (do
                 (vim.api.nvim_win_set_buf win term-buf)
                 (vim.fn.termopen cmd {:on_exit "ConjureProcessOnExit"}))]
    (match job-id
      0 (error "invalid arguments or job table full")
      -1 (error (.. "'" cmd "' is not executable")))
    (vim.api.nvim_win_set_buf win original-buf)
    (tset state.jobs job-id proc)
    (core.assoc proc :job-id job-id)))

(fn M.stop [proc]
  (when (M.running? proc)
    (vim.fn.jobstop proc.job-id)
    (M.on-exit proc.job-id))
  proc)

M
