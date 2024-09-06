(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local nvim (autoload :conjure.aniseed.nvim))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))
(local bridge (autoload :conjure.bridge))

(import-macros {: augroup : autocmd} :conjure.macros)

(config.merge
  {:client
   {:racket
    {:stdio
     {:command "racket"
      :prompt_pattern "\n?[\"%w%-./_]*> "}}}})

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

(local buf-suffix ".rkt")
(local comment-prefix "; ")
(local context-pattern "%(%s*module%s+(.-)[%s){]")
(local form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f _opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn display-result [msg]
  (log.append
    (->> (format-message msg)
         (a.filter #(not (= "" $1))))))

(fn prep-code [s]
  (let [lang-line-pat "#lang [^%s]+"
        code
        (if (s:match lang-line-pat)
          (do
            (log.append [(.. comment-prefix "Dropping #lang, only supported in file evaluation.")])
            (s:gsub lang-line-pat ""))
          s)]
    (.. code "\n(flush-output)")))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (when (and (= 1 (a.count msgs))
                     (= "" (a.get-in msgs [1 :out])))
            (a.assoc-in msgs [1 :out] (.. comment-prefix "Empty result.")))

          (opts.on-result (str.join "\n" (a.mapcat format-message msgs)))
          (a.run! display-result msgs))
        {:batch? true}))))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (.. ",require-reloadable " opts.file-path))))

(fn doc-str [opts]
  (eval-str (a.update opts :code #(.. ",doc " $1))))

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

(fn enter []
  (let [repl (state :repl)
        path (vim.fn.expand "%:p")]
    (when (and repl (not (log.log-buf? path)))
      (repl.send
        (prep-code (.. ",enter " path))
        (fn [])))))

(fn start []
  (if (state :repl)
    (log.append ["; Can't start, REPL is already running."
                 (.. "; Stop the REPL with "
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
           (enter))

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

(fn on-filetype []
  (augroup
    conjure-racket-stdio-bufenter
    (autocmd :BufEnter (.. :* buf-suffix) (bridge.viml->lua :conjure.client.racket.stdio :enter)))

  (mapping.buf
    :RktStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :RktStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :RktInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))

(fn on-exit []
  (stop))

{: buf-suffix
 : comment-prefix
 : context-pattern
 : form-node?
 : eval-str
 : interrupt
 : eval-file
 : doc-str
 : stop
 : enter
 : start
 : on-load
 : on-filetype
 : on-exit}
