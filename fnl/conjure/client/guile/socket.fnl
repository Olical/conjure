(module conjure.client.guile.socket
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             socket conjure.remote.socket
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             extract conjure.extract
             ts conjure.tree-sitter}
   require-macros [conjure.macros]})

(config.merge
  {:client
   {:guile
    {:socket
     {:mapping {:connect "cc"
                :disconnect "cd"}
      :pipename nil}}}})

(def- cfg (config.get-in-fn [:client :guile :socket]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".scm")
(def comment-prefix "; ")
(def context-pattern "%(define%-module%s+(%([%g%s]-%))")
(def form-node? ts.node-surrounded-by-form-pair-chars?)

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if (and repl (= :connected repl.status))
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(defn- format-message [msg]
  (if
    msg.out
    (text.split-lines msg.out)

    msg.err
    (-> msg.err
        (string.gsub "%s*Entering a new prompt%. .*]>%s*" "")
        (text.prefixed-lines comment-prefix))

    [(.. comment-prefix "Empty result")]))

(defn- display-result [msg]
  (log.append
    (->> (format-message msg)
         (a.filter #(not= "" $1)))))

(defn- clean-input-code [code]
  "Guile will take newlines as input and produce no result (unlike every other
  REPL I know?), so we want to strip out whitespace at either end and then just
  return nothing if it's empty. We shouldn't send code that contains nothing,
  it'll confuse the callback / message queue system."
  (let [clean (str.trim code)]
    (when (not (str.blank? clean))
      clean)))

(defn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (-?> (.. ",m " (or opts.context "(guile-user)") "\n" opts.code)
           (clean-input-code)
           (repl.send
             (fn [msgs]
               (when (and (= 1 (a.count msgs))
                          (= "" (a.get-in msgs [1 :out])))
                 (a.assoc-in msgs [1 :out] (.. comment-prefix "Empty result")))

               (opts.on-result (str.join "\n" (format-message (a.last msgs))))
               (a.run! display-result msgs))
             {:batch? true})))))

(defn eval-file [opts]
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(defn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(procedure-documentation " $1 ")"))))

(defn- display-repl-status []
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. comment-prefix
             (let [pipename (a.get-in repl [:opts :pipename])]
               (if pipename
                 (.. pipename " ")
                 ""))
             "(" repl.status
             (let [err (a.get repl :err)]
               (if err
                 (.. " " err)
                 ""))
             ")")]
        {:break? true}))))

(defn disconnect []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (a.assoc repl :status :disconnected)
      (display-repl-status)
      (a.assoc (state) :repl nil))))

(defn- parse-guile-result [s]
  (if (s:find "scheme@%([%w%-%s]+%)> ")
    (let [(ind1 ind2 result) (s:find "%$%d+ = ([^\n]+)\n")]
      {:done? true
       :error? false
       :result result})
    (if (s:find "scheme@%([%w%-%s]+%) %[%d+%]>")
      {:done? true
       :error? true
       :result nil}
      {:done? false
       :error? false
       :result s})))

(defn connect [opts]
  (disconnect)
  (let [pipename (or (cfg [:pipename]) (a.get opts :port))]
    (if (not= :string (type pipename))
      (log.append
        [(.. comment-prefix "g:conjure#client#guile#socket#pipename is not specified")
         (.. comment-prefix "Please set it to the name of your Guile REPL pipe or pass it to :ConjureConnect [pipename]")])
      (a.assoc
        (state) :repl
        (socket.start
          {:parse-output parse-guile-result
           :pipename pipename
           :on-success
           (fn []
             (display-repl-status))
           :on-error
           (fn [msg repl]
             (display-result msg)
             (repl.send ",q\n" (fn [])))
           :on-failure disconnect
           :on-close disconnect
           :on-stray-output display-result})))))

(defn on-exit []
  (disconnect))

(defn on-filetype []
  (mapping.buf
    :GuileConnect (cfg [:mapping :connect])
    #(connect)
    {:desc "Connect to a REPL"})

  (mapping.buf
    :GuileDisconnect (cfg [:mapping :disconnect])
    disconnect
    {:desc "Disconnect from the REPL"}))
