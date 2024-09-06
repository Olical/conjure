(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local socket (autoload :conjure.remote.socket))
(local str (autoload :conjure.aniseed.string))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))

(config.merge
  {:client
   {:guile
    {:socket
     {:pipename nil}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:guile
      {:socket
       {:mapping {:connect "cc"
                  :disconnect "cd"}}}}}))

(local cfg (config.get-in-fn [:client :guile :socket]))
(local state (client.new-state #(do {:repl nil})))

(local buf-suffix ".scm")
(local comment-prefix "; ")
(local context-pattern "%(define%-module%s+(%([%g%s]-%))")
(local form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if (and repl (= :connected repl.status))
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (if
    msg.out
    (text.split-lines msg.out)

    msg.err
    (-> msg.err
        (string.gsub "%s*Entering a new prompt%. .*]>%s*" "")
        (text.prefixed-lines comment-prefix))

    [(.. comment-prefix "Empty result")]))

(fn display-result [msg]
  (log.append
    (->> (format-message msg)
         (a.filter #(not= "" $1)))))

(fn clean-input-code [code]
  "Guile will take newlines as input and produce no result (unlike every other
  REPL I know?), so we want to strip out whitespace at either end and then just
  return nothing if it's empty. We shouldn't send code that contains nothing,
  it'll confuse the callback / message queue system."
  (let [clean (str.trim code)]
    (when (not (str.blank? clean))
      clean)))

(fn eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (-?> (.. ",m " (or opts.context "(guile-user)") "\n" opts.code)
           (clean-input-code)
           (repl.send
             (fn [msgs]
               (when (and (= 1 (a.count msgs))
                          (= "" (a.get-in msgs [1 :out])))
                 (a.assoc-in msgs [1 :out] (.. comment-prefix "Empty result")))

               (when opts.on-result
                (opts.on-result (str.join "\n" (format-message (a.last msgs)))))
               (a.run! display-result msgs))
             {:batch? true})))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn doc-str [opts]
  (eval-str (a.update opts :code #(.. "(procedure-documentation " $1 ")"))))

(fn display-repl-status []
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

(fn disconnect []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (a.assoc repl :status :disconnected)
      (display-repl-status)
      (a.assoc (state) :repl nil))))

(fn parse-guile-result [s]
  (let [prompt (s:find "scheme@%([%w%-%s]+%)> ")]
    (if
      prompt
      (let [(ind1 _ result) (s:find "%$%d+ = ([^\n]+)\n")
            stray-output (s:sub
                           1
                           (- (if result ind1 prompt) 1))]
        (when (> (length stray-output) 0)
          (log.append
            (-> (text.trim-last-newline stray-output)
                (text.prefixed-lines "; (out) "))))
        {:done? true
         :error? false
         :result result})

      (s:find "scheme@%([%w%-%s]+%) %[%d+%]>")
      {:done? true
       :error? true
       :result nil}

      {:done? false
       :error? false
       :result s})))

(fn connect [opts]
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

(fn on-exit []
  (disconnect))

(fn on-filetype []
  (mapping.buf
    :GuileConnect (cfg [:mapping :connect])
    #(connect)
    {:desc "Connect to a REPL"})

  (mapping.buf
    :GuileDisconnect (cfg [:mapping :disconnect])
    disconnect
    {:desc "Disconnect from the REPL"}))

{: buf-suffix
 : comment-prefix
 : connect
 : context-pattern
 : disconnect
 : doc-str
 : eval-file
 : eval-str
 : form-node?
 : on-exit
 : on-filetype}
