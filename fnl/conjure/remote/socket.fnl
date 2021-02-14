(module conjure.remote.socket
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            client conjure.client
            log conjure.log}})

(def- uv vim.loop)

(defn- parse-prompt [s pat]
  (if (s:find pat)
    (values true (s:gsub pat ""))
    (values false s)))

(defn start [opts]
  "Connects to an external REPL via a socket (TCP or named pipe), and gives you
  hooks to send code to it and read responses back out. This allows you to
  connect Conjure to a running process, but has the same problem as stdio
  clients regarding the difficulty of tying results to input.
  * opts.prompt-pattern: Identify result boundaries such as '> '.
  * opts.pipe-name: Name of the pipe
  * opts.hostname: Hostname to connect to
  * opts.port: Port number to connect to
  * opts.on-stray-output: Called with stray output that don't match up to a callback.
  * opts.on-exit: Called on exit with the code and signal."
  (let [repl-pipe (uv.new_pipe true)]

    (var repl {:queue []
               :current nil})

    (fn destroy []
      (pcall #(repl-pipe:shutdown))
      nil)

    (fn next-in-queue []
      (let [next-msg (a.first repl.queue)]
        (when (and next-msg (not repl.current))
          (table.remove repl.queue 1)
          (a.assoc repl :current next-msg)
          (log.dbg "send" next-msg.code)
          (repl-pipe:write (.. next-msg.code "\n")))))

    (fn on-message [chunk]
      (log.dbg "receive" chunk)
      (when chunk
        (let [(done? result) (parse-prompt chunk opts.prompt-pattern)
              cb (a.get-in repl [:current :cb] opts.on-stray-output)]
          (when cb
            (pcall
              #(cb {:out result
                    :done? done?})))
          (when done?
            (a.assoc repl :current nil)
            (next-in-queue)))))

    (fn on-output [err chunk]
      (on-message chunk))

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

    ;; FIXME: Open TCP socket if hostname/port given
    (when opts.pipe-name
      (when (not (= :fail (uv.pipe_connect repl-pipe opts.pipe-name)))
        (client.schedule #(opts.on-success))))

    (repl-pipe:read_start (client.schedule-wrap on-output))

    (a.merge!
      repl
      {:send send
       :opts opts
       :destroy destroy})))
