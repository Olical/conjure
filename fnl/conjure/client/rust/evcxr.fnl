(module conjure.client.rust.evcxr
  {autoload {a conjure.aniseed.core
             promise conjure.promise
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             log conjure.log
             config conjure.config
             client conjure.client}})

(def buf-suffix ".rs")
(def comment-prefix "// ")

(config.merge
  {:client
   {:rust
    {:evcxr
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "evcxr"
      :prompt_pattern ">> "}}}})


(def- cfg (config.get-in-fn [:client :rust :evcxr]))

(defonce- state (client.new-state #(do {:repl nil})))

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(defn- display-repl-status [status]
  (let [repl (state :repl)]
    (if repl
      (log.append
        [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd])) " (" status ")")]
        {:break? true})
      (log.append [status]))))

(defn- display-result [msg]
  (->> msg
       (a.map #(.. comment-prefix $1))
       log.append))

(defn- format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not (= "" $1)))
       (a.filter #(not (= "()" $1)))))

(defn- unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(defn- prep-code [s]
  (.. s "\n"))

; Start/Stop

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

(defn on-load []
  (start))

(defn on-exit []
  (stop))

(defn interrupt []
  (with-repl-or-warn
    (fn [repl]
      (let [uv vim.loop]
        (uv.kill repl.pid uv.constants.SIGINT)))))

; Eval

(defn eval-str [opts]
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

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))
