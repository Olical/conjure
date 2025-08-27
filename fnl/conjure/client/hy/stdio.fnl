(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local extract (autoload :conjure.extract))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.hy.stdio))

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
(set M.buf-suffix ".hy")
(set M.comment-prefix "; ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")
                   (.. M.comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (let [prefix (if (= true (cfg [:eval :raw_out]))
                 ""
                 (.. M.comment-prefix (if msg.err "(err)" "(out)") " "))]
    (->> (str.split (or msg.err msg.out) "\n")
         (core.filter #(~= "" $1))
         (core.map #(.. prefix $1))
         log.append)))

(fn prep-code [s]
  (.. s "\n"))

(fn M.eval-str [opts]
  (var last-value nil)
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msg]
          (log.dbg "msg" msg)
          ; (let [msgs (core.filter #(not (= "" $1)) (str.split (or msg.err msg.out) "\n"))])
          (let [msgs (->> (str.split (or msg.err msg.out) "\n")
                          (core.filter #(not (= "" $1))))]
                ; prefix (.. comment-prefix (if msg.err "(err)" "(out)") " ")]
            (set last-value (or (core.last msgs) last-value))
            ; (log.append (core.map #(.. prefix $1) msgs))
            (display-result msg)
            (when msg.done?
              ; (log.append [(.. M.comment-prefix "Finished")])
              (log.append [""])
              (when opts.on-result
                (opts.on-result last-value)))))))))

(fn M.eval-file [opts]
  (log.append [(.. M.comment-prefix "Not implemented")]))

(fn M.doc-str [opts]
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
                          (.. M.comment-prefix
                              (if msg.err "(err) " "(doc) "))))))))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (core.pr-str (core.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (core.assoc (state) :repl nil))))

(fn M.start []
  (if (state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (core.assoc
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
             (log.append [(.. M.comment-prefix "process exited with code " code)]))
           (when (and (= :number (type signal)) (> signal 0))
             (log.append [(.. M.comment-prefix "process exited with signal " signal)]))
           (M.stop))

         :on-stray-output
         (fn [msg]
           (display-result msg))}))))

(fn M.on-load []
  (M.start))

(fn M.on-exit []
  (M.stop))

(fn M.interrupt []
  (log.dbg "sending interrupt message" "")
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-filetype []
  (mapping.buf
    :HyStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :HyStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :HyInterrupt (cfg [:mapping :interrupt])
    M.interrupt
    {:desc "Interrupt the current evaluation"}))

M
