(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local remote (autoload :conjure.remote.netrepl))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))

(local buf-suffix ".janet")
(local comment-prefix "# ")
(local form-node? ts.node-surrounded-by-form-pair-chars?)
(local comment-node? ts.lisp-comment-node?)

(config.merge
  {:client
   {:janet
    {:netrepl
     {:connection {:default_host "127.0.0.1"
                   :default_port "9365"}}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:janet
      {:netrepl
       {:mapping {:connect "cc"
                  :disconnect "cd"}}}}}))

(local state (client.new-state #(do {:conn nil})))

(fn with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append ["# No connection"]))))

(fn connected? []
  (if (state :conn)
    true
    false))

(fn display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append
        [(.. "# " conn.host ":" conn.port " (" status ")")]
        {:break? true}))))

(fn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state) :conn nil))))

(fn send [opts]
  (let [{: msg : cb : row : col : file-path} opts]
    (with-conn-or-warn
      (fn [conn]
        (remote.send conn (.. "\xFF(parser/where (dyn :parser) " row " " col ")"))
        (remote.send conn
                     (.. "\xFEsource \""
                         (string.gsub file-path "\\" "\\\\")
                         "\"")
                     nil true)
        (remote.send conn msg cb true)))))

(fn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :janet :netrepl :connection :default_host]))
        port (or opts.port (config.get-in [:client :janet :netrepl :connection :default_port]))]

    (when (state :conn)
      (disconnect))

    (local conn
      (remote.connect
        {:host host
         :port port

         :on-failure
         (fn [err]
           (display-conn-status err)
           (disconnect))

         :on-success
         (fn []
           (a.assoc (state) :conn conn)
           (display-conn-status :connected))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (disconnect)))}))))

(fn try-ensure-conn []
  (when (not (connected?))
    (connect {:silent? true})))

(fn eval-str [opts]
  (try-ensure-conn)
  (send
    {:msg (.. opts.code "\n")
     :cb (fn [msg]
           (let [clean (text.trim-last-newline msg)]
             (when opts.on-result
               ;; ANSI escape trimming happens here AND in log append (if enabled)
               ;; so that "eval and replace form" won't end up inserting ANSI codes.
               (opts.on-result (text.strip-ansi-escape-sequences clean)))
             (when (not opts.passive?)
               (log.append (text.split-lines clean)))))
     :row (a.get-in opts.range [:start 1] 1)
     :col (a.get-in opts.range [:start 2] 1)
     :file-path opts.file-path}))

(fn doc-str [opts]
  (try-ensure-conn)
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

(fn eval-file [opts]
  (try-ensure-conn)
  (eval-str
    (a.assoc opts :code (.. "(do (dofile \"" opts.file-path
                            "\" :env (fiber/getenv (fiber/current))) nil)"))))

(fn on-filetype []
  (mapping.buf
    :JanetDisconnect
    (config.get-in [:client :janet :netrepl :mapping :disconnect])
    disconnect
    {:desc "Disconnect from the REPL"})

  (mapping.buf
    :JanetConnect
    (config.get-in [:client :janet :netrepl :mapping :connect])
    #(connect)
    {:desc "Connect to a REPL"}))

(fn on-load []
  (connect {}))

(fn on-exit []
  (disconnect))

{: buf-suffix
 : comment-node?
 : comment-prefix
 : connect
 : disconnect
 : doc-str
 : eval-file
 : eval-str
 : form-node?
 : on-exit
 : on-filetype
 : on-load}
