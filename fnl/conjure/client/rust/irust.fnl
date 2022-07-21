(module conjure.client.rust.irust
  {autoload {a conjure.aniseed.core
             promise conjure.promise
             nvim conjure.aniseed.nvim
             log conjure.log
             config conjure.config
             client conjure.client}})

(def buf-suffix ".rs")
(def comment-prefix "// ")

(config.merge
  {:client
   {:rust
    {:irust
     {:connection {:default_host "127.0.0.1"
                   :default_port "9000"}}}}})

(defn handle-message [err chunk]
  (a.println "handle-message" chunk err)
  (if (or err (not chunk))
    (log.dbg "receive error" err)
    (->> chunk
         (a.run!
           (fn [msg]
             (log.append [msg]))))))

(defn destroy-sock [sock]
  (when (not (sock:is_closing))
    (sock:shutdown)
    (sock:close)))

(defn tcp-send [sock msg cb prompt?]
  "Send a message to the given sock, call the callback when a response is received.
  If a prompt is expected in addition to the response, prompt? should be set to true."
  (sock:read_start (client.schedule-wrap handle-message))
  (sock:write msg)
  (sock:read_stop)
  nil)

(defn connect [opts callback]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :rust :irust :connection :default_host]))
        port (or opts.port (config.get-in [:client :rust :irust :connection :default_port]))
        sock (vim.loop.new_tcp)]
    (sock:connect host port callback)
    sock))

(defn- send [msg]
  (let [p (promise.new)]
    (def conn (connect 
                {}
                (fn [err]
                  (if err
                    (do 
                      (log.append ["error:" err])
                      (promise.deliver p :error))
                    (do 
                      (log.dbg "success:")
                      (promise.deliver p :success))))))

    (promise.await p)

    (when (= (promise.close p) :success)
      (tcp-send conn msg (fn [a] (a.println "send:" a))))

    (destroy-sock conn)))

;(send ":help")
