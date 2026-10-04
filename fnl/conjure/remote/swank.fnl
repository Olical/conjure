(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local net (autoload :conjure.net))
(local trn (autoload :conjure.remote.transport.swank))

(local M (define :conjure.remote.swank))

(fn M.message-id [msg]
  "The continuation id at the end of an :emacs-rex or :return message, or nil."
  (string.match msg "^%((:[%w-]+) .* (%d+)%)%s*$"))

(fn M.split-messages [buf]
  "Split buf into complete swank messages (6 hex digit length header, then
  the payload). Returns the messages and the unconsumed rest of buf."
  (var rest buf)
  (var done? false)
  (let [msgs []]
    (while (not done?)
      (let [len (tonumber (string.sub rest 1 6) 16)]
        (if (and len (>= (length rest) (+ 6 len)))
          (do
            (table.insert msgs (string.sub rest 7 (+ 6 len)))
            (set rest (string.sub rest (+ 7 len))))
          (set done? true))))
    (values msgs rest)))

(fn M.send [conn msg cb]
  "Send a message to the given connection, call the callback when the
  :return with the same id is received."
  ; (log.dbg "send" msg)
  (let [(_ id) (M.message-id msg)]
    (when (and id cb)
      (tset conn.callbacks id cb)))
  (conn.sock:write (trn.encode msg))
  nil)

(fn M.connect [opts]
  "Connects to a remote swank server.
  * opts.host: The host string.
  * opts.port: Port as a string.
  * opts.name: Name of the client to send post-connection, defaults to `Conjure`.
  * opts.on-failure: Function to call after a failed connection with the error.
  * opts.on-success: Function to call on a successful connection.
  * opts.on-error: Function to call when we receive an error (passed as argument) or a nil response.
  * opts.on-event: Function to call with messages that are not a :return,
    such as :debug or :write-string.
  Returns a connection table containing a `destroy` function."

  (var conn
    {:callbacks {}
     :buf ""})

  (fn dispatch [msg]
    ; (log.dbg "receive" msg)
    (let [(kind id) (M.message-id msg)
          cb (and (= ":return" kind) (. conn.callbacks id))]
      (if cb
        (do
          (tset conn.callbacks id nil)
          (cb msg))
        (when (and (not= ":return" kind) opts.on-event)
          (opts.on-event msg)))))

  (fn handle-message [err chunk]
    (if (or err (not chunk))
      (opts.on-error err)
      (let [(msgs rest) (M.split-messages (.. conn.buf chunk))]
        (set conn.buf rest)
        (each [_ msg (ipairs msgs)]
          (dispatch msg)))))

  (set conn
       (core.merge
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

  ; (M.send conn (or opts.name "Conjure"))
  conn)

M
