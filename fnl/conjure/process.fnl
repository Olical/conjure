(module conjure.process
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string}})

;; For the execution of external processes through Neovim's terminal
;; integration. This module only cares about checking for some required program
;; and then executing it with some arguments in a terminal buffer. It doesn't
;; manage the lifecycle past that point, so it's very much on it's own after it
;; begins.
;;
;; The initial use case for this is to start a babashka REPL for Clojure files
;; if no nREPL connection can be established.

(defn executable? [cmd]
  "Check if the given program name can be found on the system. If you give it a
  full command with arguments it'll just check the first word."
  (= 1 (nvim.fn.executable (a.first (str.split cmd "%s+")))))

(comment
  (executable? "bb")
  (executable? "bb nrepl-server")
  (executable? "nope-this-doesnt"))

(defn running? [proc]
  (if proc
    (. proc :running?)
    false))

(defn- on-exit [proc]
  (when (running? proc)
    (a.assoc proc :running? false)
    (pcall nvim.buf_delete (. proc :buf) {:force true})
    (let [on-exit (a.get-in proc [:opts :on-exit])]
      (when on-exit
        (on-exit proc)))))

(defn execute [cmd opts]
  (let [win (nvim.tabpage_get_win 0)
        original-buf (nvim.win_get_buf win)
        term-buf (nvim.create_buf true true)
        res {:cmd cmd :buf term-buf
             :running? true
             :opts opts}
        job-id (do
                 (nvim.win_set_buf win term-buf)
                 (nvim.fn.termopen cmd {:on_exit #(on-exit res)}))]
    (match job-id
      0 (error "invalid arguments or job table full")
      -1 (error (.. "'" cmd "' is not executable")))
    (nvim.win_set_buf win original-buf)
    (a.assoc res :job-id job-id)))

(defn stop [proc]
  (when (running? proc)
    (nvim.fn.jobstop (. proc :job-id))
    (on-exit proc))
  proc)

(comment
  (def bb (execute "bb nrepl-server"))
  (stop bb))
