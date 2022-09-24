(module conjure.client.scheme.stdio
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
   {:scheme
    {:stdio
     {:mapping {:start "cs"
                :stop "cS"}
      :command "mit-scheme"
      ;; Match "]=> " or "error> "
      :prompt_pattern "[%]e][=r]r?o?r?> "
      :value_prefix_pattern "^;Value: "}}}})

(def- cfg (config.get-in-fn [:client :scheme :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".scm")
(def comment-prefix "; ")
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

(defn format-msg [msg]
  (->> (-> msg
           (a.get :out)
           (string.gsub "^%s*" "")
           (string.gsub "%s+%d+%s*$" "")
           (str.split "\n"))
       (a.map
         (fn [line]
           (if
             (not (cfg [:value_prefix_pattern]))
             line

             (string.match line (cfg [:value_prefix_pattern]))
             (string.gsub line (cfg [:value_prefix_pattern]) "")

             (.. comment-prefix "(out) " line))))
       (a.filter #(not (str.blank? $1)))))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        (.. opts.code "\n")
        (fn [msgs]
          (let [msgs (-> msgs unbatch format-msg)]
            (opts.on-result (a.last msgs))
            (log.append msgs)))
        {:batch? true}))))

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(defn- display-repl-status [status]
  (log.append
    [(.. comment-prefix
         (cfg [:command])
         " (" (or status "no status") ")")]
    {:break? true}))

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
           (log.append (format-msg msg)))}))))

(defn on-load []
  (start))

(defn on-filetype []
  (mapping.buf
    :SchemeStart (cfg [:mapping :start])
    start
    {:desc "Start the REPL"})

  (mapping.buf
    :SchemeStop (cfg [:mapping :stop])
    stop
    {:desc "Stop the REPL"}))

(defn on-exit []
  (stop))
