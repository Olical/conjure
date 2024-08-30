(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local afs (autoload :conjure.aniseed.fs))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

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
(local state (client.new-state #(do {:repl nil})))
(local buf-suffix ".fnl")
(local comment-prefix "; ")
(local form-node? ts.node-surrounded-by-form-pair-chars?)
(local comment-node? ts.lisp-comment-node?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(fn display-result [msg]
  (log.append
    (->> (format-message msg)
         (a.filter #(not (= "" $1))))))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (when (and (= 1 (a.count msgs))
                     (= "" (a.get-in msgs [1 :out])))
            (a.assoc-in msgs [1 :out] (.. comment-prefix "Empty result.")))

          (let [msgs (a.filter #(not= ".." (. $1 :out)) msgs)]
            (when opts.on-result
              (opts.on-result (str.join "\n" (format-message (a.last msgs)))))
            (a.run! display-result msgs)))
        {:batch? true}))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn eval-reload []
  (let [file-path (nvim.fn.expand "%")
        relative-no-suf (nvim.fn.fnamemodify file-path ":.:r")
        module-path (string.gsub relative-no-suf afs.path-sep ".")]
    (log.append [(.. comment-prefix ",reload " module-path)] {:break? true})
    (eval-str
      {:action :eval
       :origin :reload
       :file-path file-path
       :code (.. ",reload " module-path)})))

(fn doc-str [opts]
  (eval-str (a.update opts :code #(.. ",doc " $1 "\n"))))

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
  (start))

(fn on-exit []
  (stop))

(fn on-filetype []
  (mapping.buf
    :FnlStart
    (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :FnlStop
    (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"})

  (mapping.buf
    :FnlEvalReload
    (cfg [:mapping :eval_reload])
    eval-reload
    {:desc "Use ,reload on the file"}))

{: buf-suffix
 : comment-prefix
 : form-node?
 : comment-node?
 : eval-str
 : eval-file
 : eval-reload
 : doc-str
 : stop
 : start
 : on-load
 : on-exit
 : on-filetype}
