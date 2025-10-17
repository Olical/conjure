(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local afs (autoload :conjure.nfnl.fs))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))
(local vim _G.vim)

(local M (define :conjure.client.fennel.stdio))

(set M.buf-suffix ".fnl")
(set M.comment-prefix "; ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)
(set M.comment-node? ts.lisp-comment-node?)

(config.merge
  {:client
   {:fennel
    {:stdio
     {:command "fennel"
      :prompt_pattern ">> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:fennel
      {:stdio
       {:mapping {:start "cs"
                  :stop "cS"
                  :eval_reload "eF"}}}}}))

(local cfg (config.get-in-fn [:client :fennel :stdio]))
(set M.state (or M.state (client.new-state #(do {:repl nil}))))

(fn with-repl-or-warn [f _opts]
  (let [repl (M.state :repl)]
    (if repl
        (f repl)
        (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn display-result [msg]
  (log.append
    (->> (format-message msg)
         (core.filter #(not (= "" $1))))))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (when (and (= 1 (core.count msgs))
                     (= "" (core.get-in msgs [1 :out])))
            (core.assoc-in msgs [1 :out] (.. M.comment-prefix "Empty result.")))

          (let [msgs (core.filter #(not= ".." (. $1 :out)) msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (format-message (core.last msgs)))))
            (core.run! display-result msgs)))
        {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (core.assoc opts :code (core.slurp opts.file-path))))

(fn M.eval-reload []
  (let [file-path (vim.fn.expand "%")
        relative-no-suf (vim.fn.fnamemodify file-path ":.:r")
        module-path (string.gsub relative-no-suf afs.path-sep ".")]
    (log.append [(.. M.comment-prefix ",reload " module-path)] {:break? true})
    (M.eval-str
      {:action :eval
       :origin :reload
       :file-path file-path
       :code (.. ",reload " module-path)})))

(fn M.doc-str [opts]
  (M.eval-str (core.update opts :code #(.. ",doc " $1 "\n"))))

(fn display-repl-status [status]
  (let [repl (M.state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (core.pr-str (core.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true}))))

(fn M.stop []
  (let [repl (M.state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (core.assoc (M.state) :repl nil))))

(fn M.start []
  (if (M.state :repl)
    (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                 (.. M.comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (core.assoc
      (M.state) :repl
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
           (display-result msg))}))))

(fn M.on-load []
  (M.start))

(fn M.on-exit []
  (M.stop))

(fn M.on-filetype []
  (mapping.buf
    :FnlStart
    (cfg [:mapping :start])
    #(M.start)
    {:desc "Start the REPL"})

  (mapping.buf
    :FnlStop
    (cfg [:mapping :stop])
    #(M.stop)
    {:desc "Stop the REPL"})

  (mapping.buf
    :FnlEvalReload
    (cfg [:mapping :eval_reload])
    #(M.eval-reload)
    {:desc "Use ,reload on the file"}))

M
