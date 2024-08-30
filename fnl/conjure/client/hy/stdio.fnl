(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local extract (autoload :conjure.extract))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(config.merge
  {:client
   {:hy
    {:stdio
     {:eval {:raw_out false}
      :command "hy -iu -c=\"Ready!\""
      :prompt_pattern "=> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:hy
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :hy :stdio]))
(local state (client.new-state #(do {:repl nil})))
(local buf-suffix ".hy")
(local comment-prefix "; ")
(local form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (let [prefix (if (= true (cfg [:eval :raw_out]))
                 ""
                 (.. comment-prefix (if msg.err "(err)" "(out)") " "))]
    (->> (str.split (or msg.err msg.out) "\n")
         (a.filter #(~= "" $1))
         (a.map #(.. prefix $1))
         log.append)))

(fn prep-code [s]
  (.. s "\n"))

(fn eval-str [opts]
  (var last-value nil)
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msg]
          (log.dbg "msg" msg)
          ; (let [msgs (a.filter #(not (= "" $1)) (str.split (or msg.err msg.out) "\n"))])
          (let [msgs (->> (str.split (or msg.err msg.out) "\n")
                          (a.filter #(not (= "" $1))))]
                ; prefix (.. comment-prefix (if msg.err "(err)" "(out)") " ")]
            (set last-value (or (a.last msgs) last-value))
            ; (log.append (a.map #(.. prefix $1) msgs))
            (display-result msg)
            (when msg.done?
              ; (log.append [(.. comment-prefix "Finished")])
              (log.append [""])
              (when opts.on-result
                (opts.on-result last-value)))))))))

(fn eval-file [opts]
  (log.append [(.. comment-prefix "Not implemented")]))

(fn doc-str [opts]
  (let [obj (when (= "." (string.sub opts.code 1 1))
              (extract.prompt "Specify object or module: "))
        obj (.. (or obj "") opts.code)
        code (.. "(if (in (mangle '" obj ") --macros--)
                    (doc " obj ")
                    (help " obj "))")]
    (with-repl-or-warn
      (fn [repl]
        (repl.send
          (prep-code code)
          (fn [msg]
            (log.append (text.prefixed-lines
                          (or msg.err msg.out)
                          (.. comment-prefix
                              (if msg.err "(err) " "(doc) "))))))))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(fn start []
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
           (display-repl-status :started)
           (with-repl-or-warn
             (fn [repl]
               (repl.send
                 (prep-code "(import sys) (setv sys.ps2 \"\") (del sys)")))))

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
           (display-result msg))}))))

(fn on-load []
  (start))

(fn on-exit []
  (stop))

(fn interrupt []
  (log.dbg "sending interrupt message" "")
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(fn on-filetype []
  (mapping.buf
    :HyStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :HyStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :HyInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))

{: buf-suffix
 : comment-prefix
 : form-node?
 : eval-str
 : eval-file
 : doc-str
 : stop
 : start
 : on-load
 : on-exit
 : interrupt
 : on-filetype}
