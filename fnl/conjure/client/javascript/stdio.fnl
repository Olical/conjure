(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local transformers (autoload :conjure.client.javascript.transformers))

(local M (define :conjure.client.javascript.stdio))

(config.merge {:client
               {:javascript
                {:stdio
                 {:args "-i"
                  :prompt-pattern "> "
                  :show_stray_out false}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:javascript
      {:stdio
       {:mapping {:start :cs
                  :stop :cS
                  :restart :cr
                  :interrupt :ei
                  :stray :ts}}}}}))

(local cfg (config.get-in-fn [:client :javascript :stdio]))
(set M.buf-suffix ".js")
(local state (client.new-state (fn [] {:repl nil})))
(set M.comment-prefix "// ")

(fn M.form-node? [node]
  (or (= :function_declaration (node:type)) (= :export_statement (node:type))
      (= :try_statement (node:type)) (= :expression_statement (node:type))
      (= :import_statement (node:type)) (= :class_declaration (node:type))
      (= :type_alias_declaration (node:type)) (= :enum_declaration  (node:type))
      (= :lexical_declaration (node:type)) (= :for_statement (node:type))
      (= :for_in_statement  (node:type)) (= :interface_declaration (node:type))))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
        (f repl)
        (log.append [(.. M.comment-prefix "No REPL running")
                     (.. M.comment-prefix "Start REPL with "
                         (config.get-in [:mapping :prefix])
                         (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (log.append msg))

(fn tap> [s] (log.append ["TAP>>" (a.pr-str s)]) s)

(fn prep-code-expr [e]
  (-> e transformers.transform))

(fn prep-code [s]
  (.. (prep-code-expr s) "\n"))

(fn replace-dots [s with]
  (let [(s _count) (string.gsub s "%.%.%.%s?" with)] s))

(fn M.format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not= "" $1))
       (a.map #(replace-dots $1 ""))))

(fn sanitize-msg [msg field]
  (->> (str.split (a.get msg field) "\n")
       (a.map #(replace-dots $1 ""))
       (a.filter (partial (not str.blank?)))
       (a.map #(.. "(" field ") " $1 "\n"))
       (str.join "")))

(fn prepare-out [msg]
  (if (a.get msg :out)
      (sanitize-msg msg :out)

      (a.get msg :err)
      (sanitize-msg msg :err)))

(fn M.unbatch [msgs]
  (->> msgs
       (a.map prepare-out)
       (str.join "")))

(fn stray-out []
  (let [status (cfg [:show_stray_out])
        on? (if status "OFF" "ON")
        _ (log.append [(.. "(STRAY OUT IS " on? ")")])]
    (config.merge {:client
                 {:javascript
                  {:stdio
                   {:show_stray_out (not status)}}}}
                {:overwrite? true})))

(fn restart []
  (M.stop)
  (M.start))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send (prep-code opts.code)
                 (fn [msgs]
                   (let [msgs (-> msgs M.unbatch M.format-msg)]
                     (display-result msgs)
                     (when opts.on-result
                       (opts.on-result (str.join " " msgs)))))
                 {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (a.pr-str (a.get-in repl [:opts :cmd]))
             " (" status ")")] {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

;; To get rid of the "Uncaught SyntaxError: Unexpected token 'export'", 
;; the REPL silently evaluates the following expression: 
(set M.initialise-repl-code "1+1")

(fn repl-command-for-filetype []
  (if
    (= :javascript vim.bo.filetype)
    "node --experimental-repl-await"

    (= :typescript vim.bo.filetype)
    "ts-node"))


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
          {:prompt-pattern (cfg [:prompt-pattern])
           :cmd (.. (repl-command-for-filetype) " " (cfg [:args]))
           :delay-stderr-ms (cfg [:delay-stderr-ms])

           :on-success
           (fn []
             (display-repl-status :started)
             (with-repl-or-warn
                 (fn [repl]
                   (repl.send
                     (prep-code M.initialise-repl-code)
                     (fn [msgs]
                       (display-result (-> msgs
                                           M.unbatch
                                           M.format-msg)))
                     {:batch true}))))

           :on-error (fn [err]
                       (display-repl-status err))

           :on-exit (fn [code signal]
                      (when (and (= :number (type code)) (> code 0))
                        (log.append
                          [(.. M.comment-prefix
                               "process exited with code "
                               code)]))
                      (when (and (= :number (type signal)) (> signal 0))
                        (log.append
                          [(.. M.comment-prefix
                               "process exited with signal "
                               signal)]))
                      (M.stop))

           :on-stray-output
           (fn [msg]
             (when (cfg [:show_stray_out])
               (display-result
                 (-> [msg] M.unbatch M.format-msg))))}))))

(fn warning-msg []
  (a.map #(log.append [$1])
         ["// WARNING! Node.js REPL limitations require transformations:"
          "// 1. ES6 'import' statements are converted to 'require(...)' calls."
          "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."]))

(fn M.on-load []
  (if (config.get-in [:client_on_load])
      (do
        (M.start)
        (warning-msg))
      (log.append ["Not starting repl"])))

(fn M.on-exit [] (M.stop))

(fn M.interrupt []
  (with-repl-or-warn
    (fn [repl]
      (log.append [(.. M.comment-prefix
                       " Sending interrupt signal.")]
                  {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-filetype []
  (mapping.buf :JavascriptStart
               (cfg [:mapping :start])
               M.start
               {:desc "Start the Javascript REPL"})
  (mapping.buf :JavascriptStop
               (cfg [:mapping :stop])
               M.stop
               {:desc "Stop the Javascript REPL"})
  (mapping.buf :JavascriptRestart
               (cfg [:mapping :restart])
               restart
               {:desc "Restart the Javascript REPL"})
  (mapping.buf :JavascriptInterrupt
               (cfg [:mapping :interrupt])
               M.interrupt
               {:desc "Interrupt the current evaluation"})
  (mapping.buf :JavascriptStray
               (cfg [:mapping :stray])
               stray-out
               {:desc "Toggle stray out"}))

M
