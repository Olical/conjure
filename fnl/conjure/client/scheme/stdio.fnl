(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))
(local cmpl (autoload :conjure.client.scheme.completions))

(local M (define :conjure.client.scheme.stdio))

(config.merge
  {:client
   {:scheme
    {:stdio
     {:command "mit-scheme"
      ;; Match "]=> " or "error> "
      :prompt_pattern "[%]e][=r]r?o?r?> "
      :value_prefix_pattern "^;Value: "
      :enable_completions true}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:scheme
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :scheme :stdio]))
(local state (client.new-state #(do {:repl nil})))

(fn completions-enabled? []
  (cfg [:enable_completions]))

(set M.buf-suffix ".scm")
(set M.comment-prefix "; ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn M.valid-str? [code] (ts.valid-str? :scheme code))
(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn M.unbatch [msgs]
  {:out (->> msgs
          (core.map #(or (core.get $1 :out) (core.get $1 :err)))
          (str.join ""))})

(fn M.format-msg [msg]
  (->> (-> msg
           (core.get :out)
           (string.gsub "^%s*" "")
           (string.gsub "%s+%d+%s*$" "")
           (str.split "\n"))
       (core.map
         (fn [line]
           (if
             (not (cfg [:value_prefix_pattern]))
             line

             (string.match line (cfg [:value_prefix_pattern]))
             (string.gsub line (cfg [:value_prefix_pattern]) "")

             (.. M.comment-prefix "(out) " line))))
       (core.filter #(not (str.blank? $1)))))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (if (M.valid-str? opts.code)
        (repl.send
          (.. opts.code "\n")
          (fn [msgs]
            (let [msgs (-> msgs M.unbatch M.format-msg)]
              (opts.on-result (core.last msgs))
              (log.append msgs)))
          {:batch? true})
       (log.append [(.. M.comment-prefix "eval error: could not parse form")])))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn display-repl-status [status]
  (log.append
    [(.. M.comment-prefix
         (cfg [:command])
         " (" (or status "no status") ")")]
    {:break? true}))

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
           (when (completions-enabled?)
             (cmpl.get-completions))
           (display-repl-status :started))

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
           (log.append (M.format-msg msg)))}))))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-load []
  (M.start))

(fn M.on-filetype []
  (mapping.buf
    :SchemeStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :SchemeStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :SchemeInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the REPL"}))

(fn M.on-exit []
  (M.stop))

(fn M.completions [opts]
  ;(when (not= nil opts)
  ;  (log.append [(.. "; completions() called with: " (core.pr-str opts))] {:break? true}))
  (if (completions-enabled?)
    (let [prefix (or (. opts :prefix) "")
          suggestions (cmpl.get-completions prefix)]
      (opts.cb suggestions))
    (opts.cb [])))

M
