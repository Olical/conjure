(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local net (autoload :conjure.net))
(local log (autoload :conjure.log))
(local client (autoload :conjure.client))
(local trn (autoload :conjure.remote.transport.netrepl))

(fn send [conn msg cb prompt?]
  "Send a message to the given connection, call the callback when a response is received.
  If a prompt is expected in addition to the response, prompt? should be set to true."
  (log.dbg "send" msg)
  (table.insert conn.queue 1 (or cb false))
  (when prompt?
    (table.insert conn.queue 1 false))
  (conn.sock:write (trn.encode msg))
  nil)

(fn connect [opts]
  "Connects to a remote netrepl server.
  * opts.host: The host string.
  * opts.port: Port as a string.
  * opts.name: Name of the client to send post-connection, defaults to `Conjure`.
  * opts.on-failure: Function to call after a failed connection with the error.
  * opts.on-success: Function to call on a successful connection.
  * opts.on-error: Function to call when we receive an error (passed as argument) or a nil response.
  Returns a connection table containing a `destroy` function."

  (var conn
    {:decode (trn.decoder)
     :queue []})

  (fn handle-message [err chunk]
    (if (or err (not chunk))
      (opts.on-error err) 
      (->> (conn.decode chunk)
           (a.run!
             (fn [msg]
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
                        (send conn (or opts.name "Conjure"))
                        (conn.sock:read_start (client.schedule-wrap handle-message))
                        (opts.on-success)))))})))

  conn)

;; Example:
; (def c (connect
;          {:host "127.0.0.1"
;           :port "9365"
;           :on-failure (fn [err] (a.println "oh no" err))
;           :on-success (fn [] (a.println "Yay!"))
;           :on-error (fn [err] (a.println "uh oh :(" err))}))
; (send c "{:hello :world}" a.println)
; (c.destroy)

{: send : connect}
