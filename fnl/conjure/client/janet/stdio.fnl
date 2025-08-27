(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.janet.stdio))

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
(set M.buf-suffix ".janet")
(set M.comment-prefix "# ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn M.unbatch [msgs]
  {:out (->> msgs
          (core.map #(or (core.get $1 :out) (core.get $1 :err)))
          (str.join ""))})

(fn format-message [msg]
  (->> (str.split msg.out "\n")
       (core.filter #(~= "" $1))))

(fn prep-code [s]
  (.. s "\n"))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (let [lines (-> msgs M.unbatch format-message)]
            (when opts.on-result
              (opts.on-result (core.last lines)))
            (log.append lines)))
        {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (core.slurp opts.file-path))))

(fn M.doc-str [opts]
  (M.eval-str (core.update opts :code #(.. "(doc " $1 ")"))))

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
           (log.append (format-message msg)))}))))

(fn M.on-load []
  (M.start))

(fn M.on-filetype []
  (mapping.buf
    :JanetStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :JanetStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"}))

(fn M.on-exit []
  (M.stop))

M
