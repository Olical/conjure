(local {: autoload} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local text (autoload :conjure.text))
(local uv vim.uv)


(fn strip-unprintable [s]
  (-> (text.strip-ansi-escape-sequences s)
      (string.gsub "[\1\2]" "")))

(fn host->addr [s]
  (let [info (uv.getaddrinfo s nil {:family "inet" :protocol "tcp"})]
    (if info
        (. info 1 :addr)
        nil)))

(fn start [opts]
  "Connects to an external REPL via a UNIX domain socket (named pipe) or a TCP
  socket, and gives you hooks to send code to it and read responses back out.
  This allows you to connect Conjure to a running process, but has the same
  problem as stdio clients regarding the difficulty of tying results to input.
  * opts.prompt-pattern: Identify result boundaries such as '> '.
  * opts.pipename: Pathname of the UNIX domain socket.
  * opts.host-port: 'hostname:port' of TCP socket.
  * opts.on-success: Called when the connection succeeds.
  * opts.on-failure: Called when the connection fails.
  * opts.on-close: Called when the connection closes.
  * opts.on-stray-output: Called with stray output that don't match up to a callback.
  * opts.on-exit: Called on exit with the code and signal."
  (let [repl {:status :pending
              :queue []
              :current nil
              :buffer ""}]

    (var handle nil) ; will be set to new_pipe or new_tcp

    (fn destroy []
      (pcall #(handle:shutdown))
      nil)

    (fn next-in-queue []
      (let [next-msg (a.first repl.queue)]
        (when (and next-msg (not repl.current))
          (table.remove repl.queue 1)
          (a.assoc repl :current next-msg)
          (log.dbg "remote.socket: send" next-msg.code)
          (handle:write (.. next-msg.code "\n")))))

    (fn on-message [chunk]
      (log.dbg "remote.socket: receive" chunk)
      (when chunk
        (let [{: done? : error? : result} (opts.parse-output chunk)
              cb (a.get-in repl [:current :cb] opts.on-stray-output)]

          (when error?
            (opts.on-error {:err repl.buffer :done? done?} repl))

          (when done?
            (when cb
              (pcall #(cb {:out result :done? done?})))
            (a.assoc repl :current nil)
            (a.assoc repl :buffer "")
            (next-in-queue)))))

    (fn on-output [err chunk]
      (if
        err
        (opts.on-failure
          (a.merge!
            repl
            {:status :failed
            :err err}))

        chunk
        (do
          (a.assoc repl :buffer (.. (a.get repl :buffer) chunk))
          (on-message (strip-unprintable (a.get repl :buffer))))

        (opts.on-close (a.assoc repl :status :closed))))

    (fn send [code cb opts]
      (table.insert
        repl.queue
        {:code code
         :cb (if (a.get opts :batch?)
               (let [msgs []]
                 (fn [msg]
                   (table.insert msgs msg)
                   (when msg.done?
                     (cb msgs))))
               cb)})
      (next-in-queue)
      nil)

    (fn on-connect [err]
      (if err
        (opts.on-failure
          (a.merge!
            repl
            {:status :failed
            :err err}))
        (do
          (opts.on-success (a.assoc repl :status :connected))
          (handle:read_start
            (client.schedule-wrap
              (fn [err chunk]
                (on-output err chunk)))))))

    ;; If both pipename and host-port are specified, use pipename.
    ;; If both pipename and host-port are not specified, log error.
    (if opts.pipename
        (do
          (log.dbg (a.str "remote.socket: pipename=" opts.pipename))
          (set handle (uv.new_pipe true))
          (uv.pipe_connect
            handle opts.pipename
            (client.schedule-wrap
              on-connect)))

        opts.host-port
        (do
          (log.dbg (a.str "remote.socket: host-port=" opts.host-port))
          (set handle (uv.new_tcp :inet))
          (let [[host port] (vim.split opts.host-port ":")
                conn_status (uv.tcp_connect
                              handle (host->addr host) (tonumber port)
                              (client.schedule-wrap
                                on-connect))]
            (log.dbg (a.str "remote.socket: host=" host))
            (log.dbg (a.str "remote.socket: port=" port))
            (log.dbg (a.str "remote.socket: conn_status=" conn_status))
            (when (not conn_status)
              (a.merge! repl {:status :failed :err (a.str "couldn't connect to " host ":" port)})
              (opts.on-failure
                (a.merge!
                  repl
                  {:status :failed
                  :err (a.str "couldn't connect to " host ":" port)})))))

        (vim.api.nvim_echo [["conjure.remote.socket: No pipename or host-port specified"]] true {:err true}))

    (log.dbg (a.str "remote.socket: repl = " repl))

    (a.merge!
      repl
      {:opts opts
       :destroy destroy
       :send send})))

{: start}
