(module conjure.client.janet.netrepl
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             bridge conjure.bridge
             mapping conjure.mapping
             text conjure.text
             log conjure.log
             config conjure.config
             client conjure.client
             remote conjure.remote.netrepl}})

(def buf-suffix ".janet")
(def comment-prefix "# ")

(config.merge
  {:client
   {:janet
    {:netrepl
     {:connection {:default_host "127.0.0.1"
                   :default_port "9365"}
      :mapping {:connect "cc"
                :disconnect "cd"}}}}})

(defonce- state (client.new-state #(do {:conn nil})))

(defn- with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append ["# No connection"]))))

(defn- connected? []
  (if (state :conn)
    true
    false))

(defn- display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append
        [(.. "# " conn.host ":" conn.port " (" status ")")]
        {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state) :conn nil))))

(defn- send [msg cb row col file-path]
  (with-conn-or-warn
    (fn [conn]
      (remote.send conn (.. "\xFF(parser/where (dyn :parser) " row " " col ")"))
      (remote.send conn (.. "\xFEsource \"" file-path "\"") nil true)
      (remote.send conn msg cb true))))

(defn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :janet :netrepl :connection :default_host]))
        port (or opts.port (config.get-in [:client :janet :netrepl :connection :default_port]))]

    (when (state :conn)
      (disconnect))

    (a.assoc
      (state) :conn
      (remote.connect
        {:host host
         :port port

         :on-failure
         (fn [err]
           (display-conn-status err)
           (disconnect))

         :on-success
         (fn []
           (display-conn-status :connected))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (disconnect)))}))))

(defn- try-ensure-conn []
  (when (not (connected?))
    (connect {:silent? true})))

(defn eval-str [opts]
  (try-ensure-conn)
  (send
    (.. opts.code "\n")
    (fn [msg]
      (let [clean (text.trim-last-newline msg)]
        (when opts.on-result
          ;; ANSI escape trimming happens here AND in log append (if enabled)
          ;; so that "eval and replace form" won't end up inserting ANSI codes.
          (opts.on-result (text.strip-ansi-escape-sequences clean)))
        (when (not opts.passive?)
          (log.append (text.split-lines clean)))))
    (or (a.get-in opts.range [:start 1]) 1)
    (or (a.get-in opts.range [:start 2]) 1)
    opts.file-path))

(defn doc-str [opts]
  (try-ensure-conn)
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

(defn eval-file [opts]
  (try-ensure-conn)
  (eval-str
    (a.assoc opts :code (.. "(do (dofile \"" opts.file-path
                            "\" :env (fiber/getenv (fiber/current))) nil)"))))

(defn on-filetype []
  (mapping.buf :n :JanetDisconnect
               (config.get-in [:client :janet :netrepl :mapping :disconnect])
               :conjure.client.janet.netrepl :disconnect)
  (mapping.buf :n :JanetConnect
               (config.get-in [:client :janet :netrepl :mapping :connect])
               :conjure.client.janet.netrepl :connect))

(defn on-load []
  (connect {}))

(defn on-exit []
  (disconnect))
