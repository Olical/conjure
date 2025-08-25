(local {: autoload : define} (require :conjure.nfnl.module))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local core (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local stdio (autoload :conjure.remote.stdio))
(local str (autoload :conjure.nfnl.string))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.racket.stdio))

(config.merge
  {:client
   {:racket
    {:stdio
     {:command "racket"
      :prompt_pattern "\n?[\"%w%-./_]*> "
      :auto_enter true}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:racket
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :racket :stdio]))
(local state (client.new-state #(do {:repl nil})))

(set M.buf-suffix ".rkt")
(set M.comment-prefix "; ")
(set M.context-pattern "%(%s*module%s+(.-)[%s){]")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f _opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn display-result [msg]
  (log.append
    (->> (format-message msg)
         (core.filter #(not (= "" $1))))))

(fn prep-code [s]
  (let [lang-line-pat "#lang [^%s]+"
        code
        (if (s:match lang-line-pat)
          (do
            (log.append [(.. M.comment-prefix "Dropping #lang, only supported in file evaluation.")])
            (s:gsub lang-line-pat ""))
          s)]
    (.. code "\n(flush-output)")))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (when (and (= 1 (core.count msgs))
                     (= "" (core.get-in msgs [1 :out])))
            (core.assoc-in msgs [1 :out] (.. M.comment-prefix "Empty result.")))

          (opts.on-result (str.join "\n" (core.mapcat format-message msgs)))
          (core.run! display-result msgs))
        {:batch? true}))))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (.. ",require-reloadable " opts.file-path))))

(fn M.doc-str [opts]
  (M.eval-str (core.update opts :code #(.. ",doc " $1))))

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

(fn M.enter []
  (let [repl (state :repl)
        path (vim.fn.expand "%:p")]
    (when (and repl (not (log.log-buf? path)) (cfg [:auto_enter]))
      (repl.send
        (prep-code (.. ",enter " path))
        (fn [])))))

(fn M.start []
  (if (state :repl)
    (log.append ["; Can't start, REPL is already running."
                 (.. "; Stop the REPL with "
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
           (M.enter))

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

(fn M.on-filetype []
  (mapping.buf
    :RktStart (cfg [:mapping :start])
    M.start
    {:desc "Start the REPL"})

  (mapping.buf
    :RktStop (cfg [:mapping :stop])
    M.stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :RktInterrupt (cfg [:mapping :interrupt])
    M.interrupt
    {:desc "Interrupt the current evaluation"}))

(fn M.on-exit []
  (M.stop))

M
