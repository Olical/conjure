(module conjure.client.janet.netrepl.server
  {require {a conjure.aniseed.core
            net conjure.net
            log conjure.log
            client conjure.client
            config conjure.config
            trn conjure.client.janet.netrepl.transport}})

(defonce- state (client.new-state #(do {:conn nil})))

(defn- with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append ["# No connection"]))))

(defn display-conn-status [status]
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

(defn- handle-message [err chunk]
  (let [conn (state :conn)]
    (if
      err (display-conn-status err)
      (not chunk) (disconnect)
      (->> (conn.decode chunk)
           (a.run!
             (fn [msg]
               (log.dbg "receive" msg)
               (let [cb (table.remove (state :conn :queue))]
                 (when cb
                   (cb msg)))))))))

(defn send [msg cb]
  (log.dbg "send" msg)
  (with-conn-or-warn
    (fn [conn]
      (table.insert (state :conn :queue) 1 (or cb false))
      (conn.sock:write (trn.encode msg)))))

(defn- handle-connect-fn [cb]
  (client.schedule-wrap
    (fn [err]
      (let [conn (state :conn)]
        (if err
          (do
            (display-conn-status err)
            (disconnect))

          (do
            (conn.sock:read_start (client.schedule-wrap handle-message))
            (send "Conjure")
            (display-conn-status :connected)))))))

(defn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :janet :netrepl :connection :default_host]))
        port (or opts.port (config.get-in [:client :janet :netrepl :connection :default_port]))]

    (when (state :conn)
      (disconnect))

    (a.assoc
      (state) :conn
      (a.merge
        (net.connect
          {:host host
           :port port
           :cb (handle-connect-fn)})
        {:decode (trn.decoder)
         :queue []}))))
