(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local stdio (autoload :conjure.remote.stdio-rt))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.snd-s7.stdio))

;;------------------------------------------------------------
;; NOTE: Uses fnl/conjure/remote/stdio-rt.fnl; not fnl/conjure/remote/stdio.fnl.
;;
;; A client for snd/s7 (sound editor with s7 scheme scripting)
;;
;; Based on: fnl/conjure/client/scheme/stdio.fnl
;;           fnl/conjure/client/sql/stdio.fnl
;;
;; The `snd` program should be runnable on the command line.
;;
;; NOTE: Conflicts with the Scheme client due to the same filetype suffix.
;;       To use this instead of the default Scheme client, set
;;       `g:conjure#filetype#scheme` to `"conjure.client.snd-s7.stdio"`.
;;       client in fnl/conjure/config.fnl.
;;------------------------------------------------------------

(config.merge
  {:client
   {:snd-s7
    {:stdio
     {:command "snd"
      :prompt_pattern "> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:snd-s7
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :snd-s7 :stdio]))
(local state (client.new-state #(do {:repl nil})))

(set M.buf-suffix ".scm")
(set M.comment-prefix "; ")
;; Use Lisp syntax.
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

;;;;-------- from client/sql/stdio.fnl ----------------------
(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(fn display-result [msg]
  (log.append (remove-blank-lines msg)))

(fn M.->list [s]
  (if (a.first s)
    s
    [s]))

;; Split string on newlines, remove trailing comments, and join lines into one
;; string. s7 doesn't handle multi-line string when sent via a subprocess.
(fn split-and-join [s]
  (str.join
    (a.map
      #(-> $1 (str.trimr) (string.gsub "%s*%;[^\n]*$" ""))
      (text.split-lines s))))

(fn M.eval-str [opts]
  (log.dbg (.. "eval-str: opts >>" (a.pr-str opts) "<<"))
  (log.dbg (.. "eval-str: opts.code >>" (a.pr-str opts.code) "<<"))

  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. (split-and-join opts.code) "\n")
        (fn [msgs]
          (let [msgs (M.->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs))
          )
        {:batch? false}))))
;;;;-------- End from client/sql/stdio.fnl ------------------

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn display-repl-status [status]
  (log.append
    [(.. M.comment-prefix
         (a.pr-str (cfg [:command]))
         " (" (or status "no status") ")")]
    {:break? true}))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(fn M.start []
  (log.append [(.. M.comment-prefix "Starting snd-s7 client...")])
  (if (state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (a.assoc
      (state) :repl
      (stdio.start
        {:prompt-pattern (cfg [:prompt_pattern])
         :cmd (cfg [:command])

         :on-success
         (fn []
           (display-repl-status :started))

         :on-error
         (fn [err]
           (display-repl-status err))

         :on-exit
         (fn [code signal]
           (log.dbg "process exited with code " (a.pr-str code))
           (log.dbg "process exited with signal " (a.pr-str signal))
           (M.stop))

         :on-stray-output
         (fn [msg]
           (display-result msg))}))))

(fn M.on-load []
  (when (config.get-in [:client_on_load])
  (M.start)))

(fn M.on-exit []
  (M.stop))

(fn M.on-filetype []
  (mapping.buf
    :SndStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :SndStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :SndInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the current REPL"}))

M
