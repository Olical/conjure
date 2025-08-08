(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.scheme.stdio))

(config.merge
  {:client
   {:scheme
    {:stdio
     {:command "mit-scheme"
      ;; Match "]=> " or "error> "
      :prompt_pattern "[%]e][=r]r?o?r?> "
      :value_prefix_pattern "^;Value: "}}}})

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
          (a.map #(or (a.get $1 :out) (a.get $1 :err)))
          (str.join ""))})

(fn M.format-msg [msg]
  (->> (-> msg
           (a.get :out)
           (string.gsub "^%s*" "")
           (string.gsub "%s+%d+%s*$" "")
           (str.split "\n"))
       (a.map
         (fn [line]
           (if
             (not (cfg [:value_prefix_pattern]))
             line

             (string.match line (cfg [:value_prefix_pattern]))
             (string.gsub line (cfg [:value_prefix_pattern]) "")

             (.. M.comment-prefix "(out) " line))))
       (a.filter #(not (str.blank? $1)))))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (if (M.valid-str? opts.code) 
        (repl.send
          (.. opts.code "\n")
          (fn [msgs]
            (let [msgs (-> msgs M.unbatch M.format-msg)]
              (opts.on-result (a.last msgs))
              (log.append msgs)))
          {:batch? true})
       (log.append [(.. M.comment-prefix "eval error: could not parse form")])))))

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

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
      (a.assoc (state) :repl nil))))

(fn M.start []
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
    M.start
    {:desc "Start the REPL"})

  (mapping.buf
    :SchemeStop (cfg [:mapping :stop])
    M.stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :SchemeInterrupt (cfg [:mapping :interrupt])
    M.interrupt
    {:desc "Interrupt the REPL"}))

(fn M.on-exit []
  (M.stop))

M
