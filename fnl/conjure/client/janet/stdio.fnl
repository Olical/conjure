(module conjure.client.janet.stdio
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             config conjure.config
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             ts conjure.tree-sitter}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:janet
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"}
      ;; -n -> disables ansi color
      ;; -s -> raw stdin (no getline functionality)
      :command "janet -n -s"
      ;; Example prompts:
      ;;
      ;; "repl:23:>"
      ;; "repl:8:(>"
      ;;
      :prompt_pattern "repl:[0-9]+:[^>]*> "
      ;; XXX: Possibly at a future date (janet -d + (debug)):
      ;;
      ;; "debug[7]:2>"
      ;; "debug[7]:2:{>"
      ;;
      ;;:prompt_pattern "(repl|debug\\[[0-9]+\\]):[0-9]+:[^>]*> "
      }}}})

(def- cfg (config.get-in-fn [:client :janet :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".janet")
(def comment-prefix "# ")
(def form-node? ts.node-surrounded-by-form-pair-chars?)

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(defn unbatch [msgs]
  {:out (->> msgs
          (a.map #(or (a.get $1 :out) (a.get $1 :err)))
          (str.join ""))})

(defn- format-message [msg]
  (->> (str.split msg.out "\n")
       (a.filter #(~= "" $1))))

(defn- prep-code [s]
  (.. s "\n"))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (prep-code opts.code)
        (fn [msgs]
          (let [lines (-> msgs unbatch format-message)]
            (when opts.on-result
              (opts.on-result (a.last lines)))
            (log.append lines)))
        {:batch? true}))))

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

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
           (log.append (format-message msg)))}))))

(defn on-load []
  (start))

(defn on-filetype []
  (mapping.buf
    :JanetStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :JanetStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"}))

(defn on-exit []
  (stop))

