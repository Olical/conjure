(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local stdio (autoload :conjure.remote.stdio-rt))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.sql.stdio))

;;------------------------------------------------------------
;; NOTE: Uses fnl/conjure/remote/stdio-rt.fnl; not fnl/conjure/remote/stdio.fnl.
;;
;; Based on fnl/conjure/client/fennel/stdio.fnl.
;;
;; The parts that are copied from that client are bracketed by the comments
;; with "from client/fennel/stdio.fnl".
;;------------------------------------------------------------

(config.merge
  {:client
   {:sql
    {:stdio
     {:command "psql postgres://postgres:postgres@localhost/postgres"
      :meta_prefix_pattern "^[.\\]%w"
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

(set M.buf-suffix ".sql")
(set M.comment-prefix "-- ")

;; Rough equivalent of a Lisp form.
(fn M.get-form-modifier [node]
  (log.dbg "get-form-modifier: node:type = " (a.pr-str (node:type)))
  (if
    ;; Must either be a statement which we have to add ; to because the
    ;; tree-sitter node excludes it for some reason.
    (= "statement" (node:type))
    {:modifier :none}

    ;; Or an unknown node that starts with a command escape character.
    ;; It has the type of ERROR at the time of writing, but this might change
    ;; if the tree sitter grammar is updated.
    ;; We have to use the :raw override because the grammar returns all
    ;; adjacent meta commands.
    ;; We just take the current line in this case.
    (a.string? (string.match (ts.node->str node) (cfg [:meta_prefix_pattern])))
    (let [line (vim.api.nvim_get_current_line)
          [row _col] (vim.api.nvim_win_get_cursor 0)]
      {:modifier :raw
       :node-table {:node node
                    :content line
                    :range {:start [row 0]
                            :end [row (a.count line)]}}})

    ;; Default to looking at the parent node.
    {:modifier :parent}))


;; Comment nodes are comment (--) and marginalia (/*...*/)
(fn M.comment-node? [node]
  (or (= "comment" (node:type))
      (= "marginalia" (node:type))))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

;;;;-------- from client/fennel/stdio.fnl ----------------------
(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn remove-blank-lines [msg]
  (->> (format-message msg)
       (a.filter #(not (= "" $1)))))

(fn display-result [msg]
  (log.append (remove-blank-lines msg)))

(fn M.->list [s]
  (if (a.first s)
    s
    [s]))

(fn M.prep-code [opts]
  (let [node (a.get opts :node)
        suffix (if (and node (= "statement" (node:type)))
                 ";\n"
                 "\n")

        ;; Removes trailing "-- ..." SQL comments from the code string
        ;; These interfere with meta commands like .tables
        ;; Only works on the last comment, intended for single lines
        ;; This is because running it across multiple lines may mangle your source code
        code (string.gsub opts.code "%s*%-%-[^\n]*$" "")]

    (.. code suffix)))

(fn M.eval-str [opts]
  (log.dbg "eval-str: opts >> " (a.pr-str opts) "<<")
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (M.prep-code opts)
        (fn [msgs]
          (let [msgs (M.->list msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (remove-blank-lines (a.last msgs)))))
            (a.run! display-result msgs)))
        {:batch? false}))))
;;;;-------- End from client/fennel/stdio.fnl ------------------

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix " Sending interrupt signal.")] {:break? true})
      (repl.send-signal :sigint))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(fn M.start []
  (log.append [(.. M.comment-prefix "Starting SQL client...")])
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
           (log.dbg "process exited with code " (a.pr-str code))
           (log.dbg "process exited with signal " (a.pr-str signal))
           (M.stop))

         :on-stray-output
         (fn [msg]
           (display-result msg))}))))

(fn M.on-load []
  (when (config.get-in [:client_on_load])
    (M.start)))

(fn M.on-exit []
  (M.stop))

(fn M.on-filetype []
  (mapping.buf
    :SqlStart (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :SqlStop (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :SqlInterrupt (cfg [:mapping :interrupt])
    #(M.interrupt)
    {:desc "Interrupt the current REPL"}))

M
