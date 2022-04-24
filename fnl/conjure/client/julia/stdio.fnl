(module conjure.client.julia.stdio
  {autoload {a conjure.aniseed.core
             extract conjure.extract
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log}
   require-macros [conjure.macros]})

; TODO prompt_pattern for julia seems to not show, empty "" is problematic.
(config.merge
  {:client
   {:julia
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"
                :interrupt "ei"}
      :command "julia --banner=no --color=no --handle-signals=no -i"
      :prompt_pattern ""}}}})

(def- cfg (config.get-in-fn [:client :julia :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".jl")
(def comment-prefix "# ")

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")
                   (.. comment-prefix
                       "Start REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :start]))]))))

(defn- prep-code [s]
  (.. s "\n"))

(defn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(defn format-msg [msg]
  (->> (str.split msg "\n")
       (a.map #(.. comment-prefix $1))))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
             (log.dbg "display of msgs" (unbatch msgs))
             (log.append (-> msgs unbatch format-msg)))
        {:batch? true}))))

(defn eval-file [opts]
  (log.append [(.. comment-prefix "Not implemented")]))

(defn doc-str [opts]
  (let [obj (when (= "." (string.sub opts.code 1 1))
              (extract.prompt "Specify object or module: "))
        obj (.. (or obj "") opts.code)
        code (.. "(if (in (mangle '" obj ") --macros--)
                    (doc " obj ")
                    (help " obj "))")]
    (with-repl-or-warn
      (fn [repl]
        (repl.send
          (prep-code code)
          (fn [msg]
            (log.append (text.prefixed-lines
                          (or msg.err msg.out)
                          (.. comment-prefix
                              (if msg.err "(err) " "(doc) "))))))))))

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
           (-> msg unbatch format-msg))}))))

(defn on-load []
  (start))

(defn on-exit []
  (stop))

(defn interrupt []
  (log.dbg "sending interrupt message" "")
  (with-repl-or-warn
    (fn [repl]
      (let [uv vim.loop]
        (uv.kill repl.pid uv.constants.SIGINT)))))

(defn on-filetype []
  (mapping.buf :n :JuliaStart (cfg [:mapping :start]) *module-name* :start)
  (mapping.buf :n :JuliaStop (cfg [:mapping :stop]) *module-name* :stop)
  (mapping.buf :n :JuliaInterrupt (cfg [:mapping :interrupt]) *module-name* :interrupt))
