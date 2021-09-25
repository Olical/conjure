(module conjure.remote.swank
  {autoload {a conjure.aniseed.core
             net conjure.net
             log conjure.log
             client conjure.client
             trn conjure.remote.transport.swank
             nvim conjure.aniseed.nvim}})

(defn send [conn msg cb]
  "Send a message to the given connection, call the callback when a response is received."
  (log.dbg "send" msg)
  (table.insert conn.queue 1 (or cb false))
  (conn.sock:write (trn.encode msg))
  nil)

(defn connect [opts]
  "Connects to a remote swank server.
  * opts.host: The host string.
  * opts.port: Port as a string.
  * opts.name: Name of the client to send post-connection, defaults to `Conjure`.
  * opts.on-failure: Function to call after a failed connection with the error.
  * opts.on-success: Function to call on a successful connection.
  * opts.on-error: Function to call when we receive an error (passed as argument) or a nil response.
  Returns a connection table containing a `destroy` function."

  (var conn
    {:decode trn.decoder
     :queue []})

  (fn handle-message [err chunk]
    (if (or err (not chunk))
      (opts.on-error err)
      (conn.decode chunk 0)))

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

  ; (send conn (or opts.name "Conjure"))
  conn)

; (def c (connect {:host "127.0.0.1"
;                  :port "4005"
;                  :on-failure (fn [err] (a.println "oh no" err))
;                  :on-success (fn [] (a.println "Yay!"))
;                  :on-error (fn [err] (a.println "uh oh" err))}))
;(send c "(:emacs-rex (swank:eval-and-grab-output \"(* 3 2)\") \"cl-user\" t 1)" log.dbg)
;(send c "(:emacs-rex (swank:list-all-package-names t) \"cl-user\" t 1)" log.dbg)
