(module conjure.proc
  {autoload {nvim conjure.aniseed.nvim}})

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

(defn execute [cmd]
  (let [win (nvim.tabpage_get_win 0)
        original-buf (nvim.win_get_buf win)
        term-buf (nvim.create_buf true true)]
    (nvim.win_set_buf win term-buf)
    (let [job-id (nvim.fn.termopen cmd)]
      (match job-id
        0 (error "invalid arguments or job table full")
        -1 (error (.. "'" cmd "' is not executable")))
      (nvim.win_set_buf win original-buf)
      {:job-id job-id
       :cmd cmd
       :buf term-buf})))

(comment
  (execute "bb nrepl-server"))
