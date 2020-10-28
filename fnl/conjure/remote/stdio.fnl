(module conjure.remote.stdio
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            client conjure.client
            log conjure.log}})

(def- uv vim.loop)

;; TODO Event hooks for success, fail, message, death.
;; TODO All results until prompt go to the front of the callback queue.
;; TODO Bundle msg with queue so we only send when ready (avoids stdin getting swallowed by past evals).
;; TODO With all msgs fn for batching where required, or maybe through an opt?

(defn start [opts]
  "Starts an external REPL and gives you hooks to send code to it and read
  responses back out. Tying an input to a result is near enough impossible
  through this stdio medium, so it's a best effort.
  * opts.prompt-pattern: Identify result boundaries such as '> '.
  * opts.cmd: Command to run to start the REPL."
  (let [stdin (uv.new_pipe false)
        stdout (uv.new_pipe false)
        stderr (uv.new_pipe false)]

    (var repl {:queue []})

    (fn destroy []
      (stdin:shutdown))

    (fn on-exit [code signal]
      (stdin:close)
      (stdout:close)
      (stderr:close)
      (repl.handle:close))

    (fn on-stdout [err chunk]
      (a.println "out:" err "-" chunk))

    (fn on-stderr [err chunk]
      (a.println "err:" err "-" chunk))

    (fn send [msg cb]
      (table.insert repl.queue cb)
      (log.dbg "send" msg)
      (stdin:write msg))

    (let [(handle pid) (uv.spawn opts.cmd {:stdio [stdin stdout stderr]} (client.wrap on-exit))]
      (stdout:read_start (client.wrap on-stdout))
      (stderr:read_start (client.wrap on-stderr))
      (a.merge!
        repl
        {:handle handle
         :pid pid
         :send send
         :destroy destroy}))))

(comment
  (def repl (start {:prompt-pattern "> "
                    :cmd "racket"}))
  (repl.send "(+ 1 2)\n"
             (fn [msg]
               (a.println "msg:" msg)))
  (repl.destroy))
