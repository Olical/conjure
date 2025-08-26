(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local stdio (autoload :conjure.remote.stdio))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text) )

(config.merge
  {:client
   {:php
    {:psysh
     {:command "psysh -ir --no-color"
      :prompt_pattern "> "
      :delay-stderr-ms 10}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:php
      {:psysh
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :php :psysh]))
(local state (client.new-state #(do {:repl nil})))
(local buf-suffix ".php")
(local comment-prefix "// ")

;; These types of nodes for PHP are roughly equivalent to Lisp forms.
(fn form-node?
  [node]
  (log.dbg "form-node?: node:type =" (node:type))
  (log.dbg "form-node?: node:parent =" (node:parent))
  (let [parent (node:parent)]
    (if (= "expression_statement" (node:type)) true
        (= "import_statement" (node:type)) true
        (= "import_from_statement" (node:type)) true
        (= "with_statement" (node:type)) true
        (= "decorated_definition" (node:type)) true
        (= "for_statement" (node:type)) true
        (= "call" (node:type)) true
        (and (= "class_definition" (node:type))
              (not (= "decorated_definition" (parent:type)))) true
        (and (= "function_definition" (node:type))
             (not (= "decorated_definition" (parent:type)))) true
        false)))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (if repl
      (log.append
        [(.. comment-prefix (core.pr-str (core.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true})
      (log.append [status]))))

(fn display-result [msg]
  (->> msg
       (core.map #(.. comment-prefix $1))
       log.append))

(fn format-msg [msg]
  (->> (str.split msg "\n")
       (core.map #(str.trim $1))
       (core.filter #(not (= "" $1)))
       (core.filter #(text.starts-with $1 "= "))
       (core.map #(string.sub $1 3))))

(fn unbatch [msgs]
  (->> msgs
       (core.map #(or (core.get $1 :out) (core.get $1 :err)))
       (str.join "")))

(fn prep-code [s]
  (.. s "\n"))

; Start/Stop

(fn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (core.assoc (state) :repl nil))))

(fn start []
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
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
                 (prep-code "help")
                 (fn [msgs]
                   (display-result (-> msgs unbatch format-msg)))
                 {:batch? true}))))

         :on-error
         (fn [err]
           (log.append ["error"])
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
           (display-result (-> [msg] unbatch format-msg) {:join-first? true}))}))))

(fn on-load []
  (start))

(fn on-exit []
  (stop))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

; Eval

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (let [msgs (-> msgs unbatch format-msg)]
            (display-result msgs)
            (when opts.on-result
              (opts.on-result (str.join " " msgs)))))
        {:batch? true}))))

(fn eval-file [opts]
  (->> (core.slurp opts.file-path)
       (core.assoc opts :code)
       eval-str))

(fn on-filetype []
  (mapping.buf
    :phpStart (cfg [:mapping :start])
    start
    {:desc "Start the PHP REPL"})

  (mapping.buf
    :phpStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the PHP REPL"})

  (mapping.buf
    :phpInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))

{: buf-suffix
 : comment-prefix
 : eval-str
 : eval-file
 : form-node?
 : interrupt
 : on-exit
 : on-filetype
 : on-load
 : start
 : stop}
