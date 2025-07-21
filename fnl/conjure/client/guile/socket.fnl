(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local socket (autoload :conjure.remote.socket))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))
(local cmpl (autoload :conjure.client.guile.completions))

(local M (define :conjure.client.guile.socket))

(config.merge
  {:client
   {:guile
    {:socket
     {:pipename nil
      :host_port nil
      :enable_completions true}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:guile
      {:socket
       {:mapping {:connect "cc"
                  :disconnect "cd"}}}}}))

(local cfg (config.get-in-fn [:client :guile :socket]))
(local state (client.new-state #(do {:repl nil :known-contexts {}})))

(set M.buf-suffix ".scm")
(set M.comment-prefix "; ")

(local base-module "(guile)")
(local default-context "(guile-user)")

(fn normalize-context [arg] 
  (let [tokens  (str.split arg "%s+") 
        context (.. "(" (str.join " " tokens) ")")]
    context))

(fn strip-comments [f]
  (string.gsub f ";.-\n" ""))

(fn M.context [f] 
  (let [stripped (strip-comments (.. f "\n"))
        define-args (string.match stripped "%(define%-module%s+%(%s*([%g%s]-)%s*%)")]
    (if define-args 
      (normalize-context define-args) 
      nil)))

(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn with-repl-or-warn [f _opts]
  (let [repl (state :repl)]
    (if (and repl (= :connected repl.status))
      (f repl)
      (log.append [(.. M.comment-prefix "No REPL running")]))))

(fn format-message [msg]
  (if
    msg.out
    (text.split-lines msg.out)

    msg.err
    (-> msg.err
        (string.gsub "%s*Entering a new prompt%. .*]>%s*" "")
        (text.prefixed-lines M.comment-prefix))

    [(.. M.comment-prefix "Empty result")]))

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

(fn completions-enabled? [] 
  (cfg [:enable_completions]))

(fn build-switch-module-command [context]
  (.. ",m " context))

(fn init-module [repl context]
  (log.dbg (.. "Initializing module for context " context))
  (repl.send 
    (.. (build-switch-module-command context) "\n,import " base-module)
    (fn [_]))
  (when (completions-enabled?)
    (repl.send 
      cmpl.guile-repl-completion-code 
      (fn [_]))))

(fn ensure-module-initialized [repl context]
  (when (not (a.get-in (state) [:known-contexts context]))
    (init-module repl context)
    (a.assoc-in (state) [:known-contexts context] true)))

(fn M.eval-str [opts]
  (with-repl-or-warn
    (fn [repl]
      (if (ts.valid-str? :scheme opts.code)
       (let [context (or opts.context default-context)]
        (ensure-module-initialized repl context) 
        (-?> (.. (build-switch-module-command context) "\n" opts.code)
             (clean-input-code)
             (repl.send
               (fn [msgs]
                 (when (and (= 1 (a.count msgs))
                            (= "" (a.get-in msgs [1 :out])))
                   (a.assoc-in msgs [1 :out] (.. M.comment-prefix "Empty result")))

                 (when opts.on-result
                   (opts.on-result (str.join "\n" (format-message (a.last msgs)))))
                 (when (not opts.passive?)
                   (a.run! display-result msgs)))
               {:batch? true})))
       (log.append [(.. M.comment-prefix "eval error: could not parse form")])))))

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn M.doc-str [opts]
  (M.eval-str (a.update opts :code #(.. ",d " $1))))

(fn display-repl-status []
  (let [repl (state :repl)]
    (log.dbg (a.str "client.guile.socket: repl=" repl))
    (when repl
      (log.append
        [(.. M.comment-prefix
             (let [pipename (a.get-in repl [:opts :pipename])
                   host-port (a.get-in repl [:opts :host_port])]
               (if pipename
                 (.. pipename " ")

                 host-port
                 (.. host-port " ")

                 "no pipename & no host-port"))
             "(" repl.status
             (let [err (a.get repl :err)]
               (if err
                 (.. " " err)
                 ""))
             ")")]
        {:break? true}))))

(fn M.disconnect []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (a.assoc repl :status :disconnected)
      (display-repl-status)
      (a.assoc (state) :repl nil)))
  (a.assoc (state) :known-contexts {}))

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

(fn M.connect [_opts]
  (M.disconnect)
  (let [pipename (cfg [:pipename])
        cfg-host-port (cfg [:host_port])
        host-port (when cfg-host-port
                    ;; Default missing parts but not fool-proof.
                    (let [[host port] (vim.split cfg-host-port ":")]
                      (log.dbg (a.str "client.guile.socket: host=" host))
                      (log.dbg (a.str "client.guile.socket: port=" port))
                      (if (and (not host) (not port))
                          "localhost:37146" ;; Guile default to listen on local port.

                          (and (not host) (tonumber port))
                          (a.str "localhost:" port)

                          (and host (not port))
                          (if (tonumber host)
                              (a.str "localhost:" host)
                              (a.str host ":37146"))
                          cfg-host-port)))]

    (log.dbg (a.str "client.guile.socket: pipename=" pipename))
    (log.dbg (a.str "client.guile.socket: host-port=" cfg-host-port))

    (a.assoc
      (state) :repl
      (socket.start
        {:parse-output parse-guile-result
        :pipename pipename
        :host-port host-port
        :on-success (fn []
                      (display-repl-status))
        :on-error (fn [msg repl]
                    (display-result msg)
                    (repl.send ",q\n" (fn []))) ; Don't bother with debugger.
        :on-failure M.disconnect
        :on-close M.disconnect
        :on-stray-output display-result}))))

(fn connected? []
  (if (state :repl)
    true
    false))

(fn busy? []
  (and (connected?) 
       (. (state :repl) :current)))

(fn M.on-exit []
  (M.disconnect))

(fn M.on-filetype []
  (mapping.buf
    :GuileConnect (cfg [:mapping :connect])
    #(M.connect)
    {:desc "Connect to a REPL"})

  (mapping.buf
    :GuileDisconnect (cfg [:mapping :disconnect])
    #(M.disconnect)
    {:desc "Disconnect from the REPL"}))

(fn M.completions [opts]
  ;(when (not= nil opts)
  ;  (log.append [(.. "; completions() called with: " (a.pr-str opts))] {:break? true}))
  (if (and (completions-enabled?) (connected?) (not (busy?)))
    (let [code (cmpl.build-completion-request opts.prefix)
          result-fn
          (fn [results]
            (let [cmpl-list (cmpl.format-results results)]
              ;(log.append [(.. "; in completions()'s result-fn, called with: " (a.pr-str results))] )
              ;(log.append [(..  "; in completions()'s result-fn, calling opts.cb with " (a.pr-str cmpl-list))])
              (opts.cb cmpl-list) ; return the list of completions
              ))
          ]
      (a.assoc opts :code code)
      (a.assoc opts :on-result result-fn)
      (a.assoc opts :passive? true)
      (M.eval-str opts))
    (opts.cb [])))

M
