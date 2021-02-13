(module conjure.client.fennel.stdio
  {require {a conjure.aniseed.core
            str conjure.aniseed.string
            nvim conjure.aniseed.nvim
            stdio conjure.remote.stdio
            config conjure.config
            text conjure.text
            mapping conjure.mapping
            client conjure.client
            log conjure.log}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:fennel
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :eval-reload "eF"}
      :command "fennel"
      :prompt-pattern ">> "}}}})

(def- cfg (config.get-in-fn [:client :fennel :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".fnl")
(def comment-prefix "; ")

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(defn- format-message [msg]
  (str.split (or msg.out msg.err) "\n"))

(defn- display-result [msg]
  (log.append
    (->> (format-message msg)
         (a.filter #(not (= "" $1))))))

(defn eval-str [opts]
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

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(defn eval-reload []
  (let [file-path (nvim.fn.expand "%")
        module-path (nvim.fn.fnamemodify file-path ":.:r")]
    (log.append [(.. comment-prefix ",reload " module-path)] {:break? true})
    (eval-str
      {:action :eval
       :origin :reload
       :file-path file-path
       :code (.. ",reload " module-path)})))

(defn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(doc " $1 ")\n"))))

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
  (if (state :repl)
    (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                 (.. comment-prefix "Stop the REPL with "
                     (config.get-in [:mapping :prefix])
                     (cfg [:mapping :stop]))]
                {:break? true})
    (a.assoc
      (state) :repl
      (stdio.start
        {:prompt-pattern (cfg [:prompt-pattern])
         :cmd (cfg [:command])
         :env ["INPUTRC=/dev/null"]

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

(defn on-load []
  (start))

(defn on-filetype []
  (mapping.buf :n :FnlStart
               (cfg [:mapping :start]) *module-name* :start)
  (mapping.buf :n :FnlStop
               (cfg [:mapping :stop]) *module-name* :stop)
  (mapping.buf :n :FnlEvalReload
               (cfg [:mapping :eval-reload]) *module-name* :eval-reload))
