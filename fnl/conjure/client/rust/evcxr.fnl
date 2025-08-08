(local {: autoload} (require :conjure.nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local stdio (autoload :conjure.remote.stdio))
(local str (autoload :conjure.aniseed.string))

(local buf-suffix ".rs")
(local comment-prefix "// ")

(config.merge
  {:client
   {:rust
    {:evcxr
     {:command "evcxr"
      :prompt_pattern ">> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:rust
      {:evcxr
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :rust :evcxr]))
(local state (client.new-state #(do {:repl nil})))

;; These types of nodes for Rust are roughly equivalent to Lisp forms.
;;   struct_item
;;   let_declaration
;;   expression_statement
;;   struct_item
;;   index_expression
(fn form-node?
  [node]
  (log.dbg "form-node?: node:type =" (node:type))
  (log.dbg "form-node?: node:parent =" (node:parent))
  (let [parent (node:parent)]
    (if (= "struct_item" (node:type)) true
        (= "let_declaration" (node:type)) true
        (= "index_expression" (node:type)) true
        (= "expression_statement" (node:type)) true
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
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true})
      (log.append [status]))))

(fn display-result [msg]
  (->> msg
       (a.map #(.. comment-prefix $1))
       log.append))

(fn format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not (= "" $1)))
       (a.filter #(not (= "()" $1)))))

(fn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(fn prep-code [s]
  (.. s "\n"))

; Start/Stop

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
                 (prep-code ":help")
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
      (repl.send-signal vim.uv.constants.SIGINT))))

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
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn on-filetype []
  (mapping.buf
    :RustStart (cfg [:mapping :start])
    start
    {:desc "Start the Rust REPL"})

  (mapping.buf
    :RustStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the Rust REPL"})

  (mapping.buf
    :RustInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current evaluation"}))

{: buf-suffix
 : comment-prefix
 : eval-file
 : eval-str
 : form-node?
 : interrupt
 : on-exit
 : on-filetype
 : on-load
 : start
 : stop}
