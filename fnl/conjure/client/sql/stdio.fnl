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
     {:command "psql -U blogger postgres"
      :prompt_pattern "=> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:sql
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

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
(defn- format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(defn- remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(defn- display-result [msg]
  (log.append (remove-blank-lines msg)))

(defn ->list [s]
  (if (a.first s)
    s
    [s]))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (let [msgs (->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs))
          )
        {:batch? false}))))
;;;;-------- End from client/fennel/stdio.fnl ------------------

(defn eval-file [opts]
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
