(module conjure.remote.swank
  {autoload {a conjure.aniseed.core
             net conjure.net
             log conjure.log
             client conjure.client
             trn conjure.remote.transport.slynk
             nvim conjure.aniseed.nvim}})

;;;; Slynk Transport layer for common lisp
;;;; This module should focus on interactions in the 
;;;; transport layer for slynk, such as connecting
;;;; and sending messages.

(defn send [conn msg cb]
  "Send `msg` to the connection `conn` and call `cb` with the result."
  (table.insert conn.queue 1 (or cb false))
  ;; Note that we encode using conjure.remote.transport.slynk
  (conn.sock:write (trn.encode msg))
  nil)

(defn connect [opts]
  "Connects to a remote slynk server.
  * opts.host: The host string.
  * opts.port: Port as a string.
  * opts.name: Name of the client to send post-connection, defaults to `Conjure`.
  * opts.on-failure: Function to call after a failed connection with the error.
  * opts.on-success: Function to call on a successful connection.
  * opts.on-error: Function to call when we receive an error (passed as argument) or a nil response.
  Returns a connection table containing a `destroy` function."

  (var conn
    {:decode trn.decode
     :queue []})

  (fn handle-message [err chunk]
    (if (or err (not chunk))
      (opts.on-error err)
      (->> (conn.decode chunk)
           ((fn [msg]
              (log.dbg "receive" msg)
              (let [cb (table.remove conn.queue)]
                (when cb
                  (cb msg))))))))

  (set conn
       (a.merge
         conn
         (net.connect
           {:host opts.host
            :port opts.port
            :cb (client.schedule-wrap
                  (fn [err]
                    (if err
                      (opts.on-failure err)

                      (do
                        (conn.sock:read_start (client.schedule-wrap handle-message))
                        (opts.on-success)))))})))

  ;; any post-connect commands should be sent here, such as reporting features and 
  ;; setting options.
  ; (send conn (or opts.name "Conjure"))
  conn)

