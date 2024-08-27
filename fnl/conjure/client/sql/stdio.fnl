(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local stdio (autoload :conjure.remote.stdio-rt))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))

(import-macros {: augroup : autocmd} :conjure.macros)

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
     {:command "psql postgres://postgres:postgres@localhost/postgres"
      :prompt_pattern "=> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:sql
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :interrupt "ei"}}}}}))

(local cfg (config.get-in-fn [:client :sql :stdio]))
(local state (client.new-state #(do {:repl nil})))

(local buf-suffix ".sql")
(local comment-prefix "-- ")

;; Rough equivalent of a Lisp form.
(fn form-node? [node]
  (or (= "statement" (node:type))))

;; Comment nodes are comment (--) and marginalia (/*...*/)
(fn comment-node? [node]
  (or (= "comment" (node:type))
      (= "marginalia" (node:type))))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

;;;;-------- from client/fennel/stdio.fnl ----------------------
(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(fn display-result [msg]
  (log.append (remove-blank-lines msg)))

(fn ->list [s]
  (if (a.first s)
    s
    [s]))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code ";\n")
        (fn [msgs]
          (let [msgs (->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs)))
        {:batch? false}))))
;;;;-------- End from client/fennel/stdio.fnl ------------------

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal vim.loop.constants.SIGINT))))

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
  (log.append [(.. comment-prefix "Starting SQL client...")])
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
           (display-result msg))}))))

(fn on-load []
  (when (config.get-in [:client_on_load])
    (start)))

(fn on-exit []
  (stop))

(fn on-filetype []
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

{
 : buf-suffix
 : comment-prefix
 : form-node?
 : comment-node?
 : ->list
 : eval-str
 : eval-file
 : interrupt
 : stop
 : start
 : on-load
 : on-exit
 : on-filetype
 }
