(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local str (autoload :conjure.aniseed.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local stdio (autoload :conjure.remote.stdio-rt))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local ts (autoload :conjure.tree-sitter))

;;------------------------------------------------------------
;; A client for snd/s7 (sound editor with s7 scheme scripting)
;;
;; Based on: fnl/conjure/client/scheme/stdio.fnl
;;           fnl/conjure/client/sql/stdio.fnl
;;
;; Uses fnl/conjure/remote/stdio-rt.fnl; not fnl/conjure/remote/stdio.fnl.
;;
;; The `snd` program should be runnable on the command line.
;;
;; NOTE: Conflicts with the Scheme client due to the same filetype suffix.
;;       To use this instead of the default Scheme client, set
;;       `g:conjure#filetype#scheme` to `"conjure.client.snd-s7.stdio"`.
;;       client in fnl/conjure/config.fnl.
;;
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
(local buf-suffix ".scm")
(local comment-prefix "; ")
(local form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

;;;;-------- from client/sql/stdio.fnl ----------------------
(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(fn display-result [msg]
  (log.append (remove-blank-lines msg)))

(fn ->list [s]
  (if (a.first s)
    s
    [s]))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (let [msgs (->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs))
          )
        {:batch? false}))))
;;;;-------- End from client/sql/stdio.fnl ------------------

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(fn display-repl-status [status]
  (log.append
    [(.. comment-prefix
         (cfg [:command])
         " (" (or status "no status") ")")]
    {:break? true}))

(fn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(fn start []
  (log.append [(.. comment-prefix "Starting snd-s7 client...")])
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
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
           (when (and (= :number (type code)) (> code 0))
             (log.append [(.. comment-prefix "process exited with code " code)]))
           (when (and (= :number (type signal)) (> signal 0))
             (log.append [(.. comment-prefix "process exited with signal " signal)]))
           (stop))

         :on-stray-output
         (fn [msg]
           (log.append (format-msg msg)))}))))

(fn on-load []
  (when (config.get-in [:client_on_load])
  (start)))

(fn on-exit []
  (stop))

(fn on-filetype []
  (mapping.buf
    :SndStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :SndStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :SdnInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the REPL"}))

{: buf-suffix
 : comment-prefix
 : form-node?
 : ->list
 : eval-str
 : eval-file
 : interrupt
 : stop
 : start
 : on-load
 : on-exit
 : on-filetype}
