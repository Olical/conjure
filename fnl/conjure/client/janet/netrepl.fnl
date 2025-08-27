(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local remote (autoload :conjure.remote.netrepl))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.hy.stdio))

(set M.buf-suffix ".janet")
(set M.comment-prefix "# ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)
(set M.comment-node? ts.lisp-comment-node?)

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

(fn M.disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (core.assoc (state) :conn nil))))

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

(fn M.connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :janet :netrepl :connection :default_host]))
        port (or opts.port (config.get-in [:client :janet :netrepl :connection :default_port]))]

    (when (state :conn)
      (M.disconnect))

    (local conn
      (remote.connect
        {:host host
         :port port

         :on-failure
         (fn [err]
           (display-conn-status err)
           (M.disconnect))

         :on-success
         (fn []
           (core.assoc (state) :conn conn)
           (display-conn-status :connected))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (M.disconnect)))}))))

(fn try-ensure-conn []
  (when (not (connected?))
    (M.connect {:silent? true})))

(fn M.eval-str [opts]
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
     :row (core.get-in opts.range [:start 1] 1)
     :col (core.get-in opts.range [:start 2] 1)
     :file-path opts.file-path}))

(fn M.doc-str [opts]
  (try-ensure-conn)
  (M.eval-str (core.update opts :code #(.. "(doc " $1 ")"))))

(fn M.eval-file [opts]
  (try-ensure-conn)
  (M.eval-str
    (core.assoc opts :code (.. "(do (dofile \"" opts.file-path
                            "\" :env (fiber/getenv (fiber/current))) nil)"))))

(fn M.on-filetype []
  (mapping.buf
    :JanetDisconnect
    (config.get-in [:client :janet :netrepl :mapping :disconnect])
    #(M.disconnect)
    {:desc "Disconnect from the REPL"})

  (mapping.buf
    :JanetConnect
    (config.get-in [:client :janet :netrepl :mapping :connect])
    #(M.connect)
    {:desc "Connect to a REPL"}))

(fn M.on-load []
  (M.connect {}))

(fn M.on-exit []
  (M.disconnect))

M
