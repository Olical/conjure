(module conjure.process
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core}})

;; For the execution of external processes through Neovim's terminal
;; integration. This module only cares about checking for some required program
;; and then executing it with some arguments in a terminal buffer. It doesn't
;; manage the lifecycle past that point, so it's very much on it's own after it
;; begins.
;;
;; The initial use case for this is to start a babashka REPL for Clojure files
;; if no nREPL connection can be established.

(defn executable? [name]
  "Check if the given program name can be found on the system."
  (= 1 (nvim.fn.executable name)))

(comment
  (executable? "bb")
  (executable? "nope-this-doesnt"))

(defn running? [proc]
  (. proc :running?))

(defn- on-exit [proc]
  (when (running? proc)
    (a.assoc proc :running? false)
    (pcall nvim.buf_delete (. proc :buf) {:force true})))

(defn execute [cmd]
  (let [win (nvim.tabpage_get_win 0)
        original-buf (nvim.win_get_buf win)
        term-buf (nvim.create_buf true true)
        res {:cmd cmd :buf term-buf :running? true}
        opts {:on_exit #(on-exit res)}]
    (nvim.win_set_buf win term-buf)
    (let [job-id (nvim.fn.termopen cmd opts)]
      (match job-id
        0 (error "invalid arguments or job table full")
        -1 (error (.. "'" cmd "' is not executable")))
      (nvim.win_set_buf win original-buf)
      (a.assoc res :job-id job-id))))

(defn stop [proc]
  (when (running? proc)
    (nvim.fn.jobstop (. proc :job-id))
    (on-exit proc))
  proc)

(comment
  (def bb (execute "bb nrepl-server"))
  (stop bb))
