(module conjure.client.racket.stdio
  {require {a conjure.aniseed.core
            str conjure.aniseed.string
            stdio conjure.remote.stdio
            config conjure.config
            text conjure.text
            client conjure.client
            log conjure.log}})

(config.merge
  {:client
   {:racket
    {:stdio
     {:command "racket"
      :prompt-pattern "\n?[%w%-]*> $"}}}})

(def- cfg (config.get-in-fn [:client :racket :stdio]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".rkt")
(def comment-prefix "; ")
(def context-pattern "%(%s*module%s+(.-)[%s){]")

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(defn- format-message [msg]
  (if
    msg.out (str.split msg.out "\n")
    msg.err (text.prefixed-lines msg.err) (.. comment-prefix "(err) ")))

(defn- display-result [msg]
  (log.append (format-message msg)))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (repl.send
        opts.code
        (fn [msgs]
          (when (and (= 1 (a.count msgs))
                     (= "" (a.get-in msgs [1 :out])))
            (a.assoc-in msgs [1 :out] (.. comment-prefix "Empty result.")))

          (opts.on-result (str.join "\n" (format-message (a.last msgs))))
          (a.run! display-result msgs))
        {:batch? true}))))

(defn- display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix (a.get-in repl [:opts :cmd]) " (" status ")")]
        {:break? true}))))

(defn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(defn start []
  (stop)
  (a.assoc
    (state) :repl
    (stdio.start
      {:prompt-pattern (cfg [:prompt-pattern])
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
         (display-result msg))})))

(defn on-load []
  (start))
