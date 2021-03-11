(module conjure.remote.stdio
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

(defn parse-cmd [x]
  (if
    (a.table? x)
    {:cmd (a.first x)
     :args (a.rest x)}

    (a.string? x)
    (parse-cmd (str.split x "%s"))))

(defn- extend-env [vars]
  (->> (a.merge
         (nvim.fn.environ)
         vars)
       (a.kv-pairs)
       (a.map
         (fn [[k v]]
           (.. k "=" v)))))

(defn start [opts]
  "Starts an external REPL and gives you hooks to send code to it and read
  responses back out. Tying an input to a result is near enough impossible
  through this stdio medium, so it's a best effort.
  * opts.prompt-pattern: Identify result boundaries such as '> '.
  * opts.cmd: Command to run to start the REPL.
  * opts.args: Arguments to pass to the REPL.
  * opts.on-error: Called with an error string when we receive a true error from the process.
  * opts.on-stray-output: Called with stray output that don't match up to a callback.
  * opts.on-exit: Called on exit with the code and signal."
  (let [stdin (uv.new_pipe false)
        stdout (uv.new_pipe false)
        stderr (uv.new_pipe false)]

    (var repl {:queue []
               :current nil})

    (fn destroy []
      (when repl.handle
        (uv.process_kill repl.handle))
      nil)

    (fn on-exit [code signal]
      (destroy)
      (client.schedule opts.on-exit code signal))

    (fn next-in-queue []
      (let [next-msg (a.first repl.queue)]
        (when (and next-msg (not repl.current))
          (table.remove repl.queue 1)
          (a.assoc repl :current next-msg)
          (log.dbg "send" next-msg.code)
          (stdin:write next-msg.code))))

    (fn on-message [source err chunk]
      (log.dbg "receive" source err chunk)
      (if err
        (do
          (opts.on-error err)
          (destroy))
        (when chunk
          (let [(done? result) (parse-prompt chunk opts.prompt-pattern)
                cb (a.get-in repl [:current :cb] opts.on-stray-output)]
            (when cb
              (pcall
                #(cb {source result
                      :done? done?})))
            (when done?
              (a.assoc repl :current nil)
              (next-in-queue))))))

    (fn on-stdout [err chunk]
      (on-message :out err chunk))

    (fn on-stderr [err chunk]
      (on-message :err err chunk))

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

    (let [{: cmd : args} (parse-cmd opts.cmd)
          (handle pid) (uv.spawn cmd {:stdio [stdin stdout stderr]
                                      :args args
                                      :env (extend-env
                                             ;; Disable custom readline config.
                                             {:INPUTRC "/dev/null"})}
                                 (client.schedule-wrap on-exit))]
      (stdout:read_start (client.schedule-wrap on-stdout))
      (stderr:read_start (client.schedule-wrap on-stderr))
      (client.schedule #(opts.on-success))
      (a.merge!
        repl
        {:handle handle
         :pid pid
         :send send
         :opts opts
         :destroy destroy}))))
