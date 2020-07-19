(module conjure.client.janet.netrepl.server
  {require {ui conjure.client.janet.netrepl.ui
            a conjure.aniseed.core
            net conjure.net
            log conjure.log
            client conjure.client
            config conjure.config
            trn conjure.client.janet.netrepl.transport}})

(client.init-state
  [:janet :netrepl]
  {:conn nil})

(def- state (client.state-fn :janet :netrepl))

(defn- with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (ui.display ["# No connection"]))))

(defn display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (ui.display
        [(.. "# " conn.raw-host ":" conn.port " (" status ")")]
        {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (when (not (conn.sock:is_closing))
        (conn.sock:read_stop)
        (conn.sock:shutdown)
        (conn.sock:close))
      (display-conn-status :disconnected)
      (a.assoc (state) :conn nil))))

(defn- dbg [...]
  (client.with-filetype :janet log.dbg ...))

(defn- handle-message [err chunk]
  (let [conn (state :conn)]
    (if
      err (display-conn-status err)
      (not chunk) (disconnect)
      (->> (conn.decode chunk)
           (a.run!
             (fn [msg]
               (dbg "receive" msg)
               (let [cb (table.remove (state :conn :queue))]
                 (when cb
                   (cb msg)))))))))

(defn send [msg cb]
  (dbg "send" msg)
  (with-conn-or-warn
    (fn [conn]
      (table.insert (state :conn :queue) 1 (or cb false))
      (conn.sock:write (trn.encode msg)))))

(defn- handle-connect-fn [cb]
  (vim.schedule_wrap
    (fn [err]
      (let [conn (state :conn)]
        (if err
          (do
            (display-conn-status err)
            (disconnect))

          (do
            (conn.sock:read_start (vim.schedule_wrap handle-message))
            (send "Conjure")
            (display-conn-status :connected)))))))

(defn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :janet :netrepl :connection :default_host]))
        port (or opts.port (config.get-in [:client :janet :netrepl :connection :default_port]))
        resolved-host (net.resolve host)
        conn {:sock (vim.loop.new_tcp)
              :host resolved-host
              :raw-host host
              :port port
              :decode (trn.decoder)
              :queue []}]

    (when (state :conn)
      (disconnect))

    (a.assoc (state) :conn conn)
    (conn.sock:connect resolved-host port (handle-connect-fn))))
