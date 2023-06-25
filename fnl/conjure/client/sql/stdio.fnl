(module conjure.client.sql.stdio
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio-rt
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             ts conjure.tree-sitter}
   require-macros [conjure.macros]})

;;------------------------------------------------------------
;; Set-up:
;; ✅ 1. Copy from client/fennel/stdio.fnl.
;; ❌ 2. Also, try client/python/stdio.fnl which differs in the eval-str
;;       function and its helpers.
;;
;; Problems:
;; ✅ 1. Only the first send (,ee) works. Subsequent ones don't have any effect.
;; ✅ 2. The response from a send is not displayed in the log buffer.
;;    3. I don't see the prompt from REPL in the debug log.
;;         - Should we be waiting to see the prompt before acting on the next
;;           message in queue?
;;
;;------------------------------------------------------------

;;------------------------------------------------------------
;; Based on fnl/conjure/client/fennel/stdio.fnl.
;;
;; May work with other command line SQL clients besides PostgresQL's psql.
;;
;; Set up psql to use ~/.pgpass.
;;   - https://www.postgresql.org/docs/14/libpq-pgpass.html
;;
;;   For "psql -U blogger postgres", use:
;;     localhost:5432:postgres:blogger:secret
;;
;;   where the blogger user has been created in the postgres database.
;;------------------------------------------------------------

(config.merge
  {:client
   {:sql
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "psql -U blogger postgres"
      :prompt_pattern "=> "
      }}}})

(def- cfg (config.get-in-fn [:client :sql :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".sql")
(def comment-prefix "-- ")
;; Rough equivalent of a Lisp form.
(defn form-node? [node]
  (or (= "statement" (node:type))))
;; Comment nodes are comment (--) and marginalia (/*...*/)
(defn comment-node? [node]
  (or (= "comment" (node:type))
      (= "marginalia" (node:type))
      ))

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

;;;;-------- from client/fennel/stdio.fnl ----------------------
; source is :out or :err
(defn- format-message [msg]
  (log.dbg (.. comment-prefix "  sql.format-message [msg]") (a.pr-str msg))
  (str.split (or msg.out msg.err) "\n"))

(defn- remove-blank-lines [msg]
  (log.dbg (.. comment-prefix "  sql.remove-blank-lines [msg]") (a.pr-str msg))
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(defn- display-result [msg]
  (log.dbg (.. comment-prefix "  sql.display-result [msg]") (a.pr-str msg))
  (log.append (remove-blank-lines msg)))

; Helper: Convert arg to a list.
(defn ->list [s]
  (if (a.first s)
    s
    [s]))

; From client/fennel/stdio.fnl
(defn eval-str [opts]
  (log.dbg (.. comment-prefix "eval-str [opts] ") (a.pr-str opts))
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (log.dbg (.. comment-prefix "  sql.eval-str in cb [opts]") (a.pr-str opts))
          (log.dbg (.. comment-prefix "  sql.eval-str in cb [msgs]") (a.pr-str msgs))
          (let [msgs (->list msgs)]
            (when opts.on-result ; eval.fnl sets this to display results in source buffer
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs)) ; in log buffer
          ) ; (fn [msgs]...
        {:batch? false})))) ; should probably be false
;;;;-------- End from client/fennel/stdio.fnl ------------------

(defn eval-file [opts]
  (log.dbg (.. comment-prefix "eval-file [opts] ") (a.pr-str opts))
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(defn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

(defn- display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(defn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(defn start []
  (log.append [(.. comment-prefix "start [] ")])
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (do
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
             (display-result msg))
           })))))

(defn on-load []
  (when (config.get-in [:client_on_load])
    (start)))

(defn on-exit []
  (stop))

(defn on-filetype []
  (mapping.buf
    :SqlStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :SqlStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :SqlInterrupt (cfg [:mapping :interrupt])
    interrupt
    {:desc "Interrupt the current REPL"}))
