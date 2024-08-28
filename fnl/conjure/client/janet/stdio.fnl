(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
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
   {:janet
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"}
      ;; -n -> disables ansi color
      ;; -s -> raw stdin (no getline functionality)
      :command "janet -n -s"
      ;; Example prompts:
      ;;
      ;; "repl:23:>"
      ;; "repl:8:(>"
      ;;
      :prompt_pattern "repl:[0-9]+:[^>]*> "
      ;; XXX: Possibly at a future date (janet -d + (debug)):
      ;;
      ;; "debug[7]:2>"
      ;; "debug[7]:2:{>"
      ;;
      ;;:prompt_pattern "(repl|debug\\[[0-9]+\\]):[0-9]+:[^>]*> "
      }}}})

(local cfg (config.get-in-fn [:client :janet :stdio]))
(local state (client.new-state #(do {:repl nil})))
(local buf-suffix ".janet")
(local comment-prefix "# ")
(local form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(fn unbatch [msgs]
  {:out (->> msgs
          (a.map #(or (a.get $1 :out) (a.get $1 :err)))
          (str.join ""))})

(fn format-message [msg]
  (->> (str.split msg.out "\n")
       (a.filter #(~= "" $1))))

(fn prep-code [s]
  (.. s "\n"))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (let [lines (-> msgs unbatch format-message)]
            (when opts.on-result
              (opts.on-result (a.last lines)))
            (log.append lines)))
        {:batch? true}))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

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
           (log.append (format-message msg)))}))))

(fn on-load []
  (start))

(fn on-filetype []
  (mapping.buf
    :JanetStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :JanetStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"}))

(fn on-exit []
  (stop))

{: buf-suffix
 : comment-prefix
 : form-node?
 : unbatch
 : eval-str
 : eval-file
 : doc-str
 : stop
 : start
 : on-load
 : on-filetype
 : on-exit}
