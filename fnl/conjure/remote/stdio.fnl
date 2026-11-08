(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local process (autoload :conjure.process))

(local M (define :conjure.remote.stdio))
(local vim _G.vim)
(local uv vim.uv)

(config.merge
  {:stdio {:silence_missing_command false}})


(fn parse-prompt [s pat]
  (if (s:find pat)
    (values true (s:gsub pat ""))
    (values false s)))

(fn M.parse-cmd [x]
  (if
    (core.table? x)
    {:cmd (core.first x)
     :args (core.rest x)}

    (core.string? x)
    (M.parse-cmd (str.split x "%s"))))

(fn extend-env [vars]
  (->> (core.merge
         (vim.fn.environ)
         vars)
       (core.kv-pairs)
       (core.map
         (fn [[k v]]
           (.. k "=" v)))))

(fn M.start [opts]
  "Starts an external REPL and gives you hooks to send code to it and read
  responses back out. Tying an input to a result is near enough impossible
  through this stdio medium, so it's a best effort.
  * opts.prompt-pattern: Identify result boundaries such as '> '.
  * opts.preserve-prompt?: Keep prompts in responses for clients that strip them after batching.
  * opts.await-initial-prompt?: Hold back the first send until the prompt printed on startup arrives,
                                for REPLs that always print one. Otherwise that prompt can complete
                                the first send before its output arrives.
  * opts.cmd: Command to run to start the REPL.
  * opts.args: Arguments to pass to the REPL.
  * opts.on-error: Called with an error string when we receive a true error from the process.
  * opts.delay-stderr-ms: If passed, delays the call to on-error for this many milliseconds. This
                          is a workaround for clients like python whose prompt on stderr sometimes
                          arrives before the previous command's output on stdout.
  * opts.on-stray-output: Called with stray output that don't match up to a callback.
  * opts.on-exit: Called on exit with the code and signal."
  (let [{: cmd : args} (M.parse-cmd opts.cmd)]
    (if (not (process.executable? cmd))
      (do
        (when (not (config.get-in [:stdio :silence_missing_command]))
          (client.schedule
            #(opts.on-error
               (.. "command not found: " cmd
                   " (is it installed and on your $PATH?)"))))
        nil)

      (let [stdin (uv.new_pipe false)
            stdout (uv.new_pipe false)
            stderr (uv.new_pipe false)
            repl {:queue []
                  :current (when opts.await-initial-prompt? {})}]

        (fn destroy []
          ;; https://teukka.tech/vimloop.html
          (pcall #(stdout:read_stop))
          (pcall #(stderr:read_stop))
          (pcall #(stdout:close))
          (pcall #(stderr:close))
          (pcall #(stdin:close))
          (when repl.handle
            (pcall #(uv.process_kill repl.handle :sigterm))
            (pcall #(repl.handle:close)))
          nil)

        (fn on-exit [code signal]
          (destroy)
          (client.schedule opts.on-exit code signal))

        (fn next-in-queue []
          (let [next-msg (core.first repl.queue)]
            (when (and next-msg (not repl.current))
              (table.remove repl.queue 1)
              (core.assoc repl :current next-msg)
              (log.dbg (.. "remote.stdio.next-in-queue; sending next-msg.code:'" (core.str next-msg.code) "'"))
              (stdin:write next-msg.code))))

        (fn on-message [source err chunk]
          (log.dbg (.. "remote.stdio.on-message; from:" source ", err:'" (core.str err) "', chunk:'" (core.str chunk) "'"))
          (if err
            (do
              (opts.on-error err)
              (destroy))
            (when chunk
              (let [(done? result) (parse-prompt chunk opts.prompt-pattern)
                    cb (core.get-in repl [:current :cb] opts.on-stray-output)]
                (when cb
                  (pcall
                    #(cb {source (if opts.preserve-prompt? chunk result)
                          :done? done?})))
                (when done?
                  (core.assoc repl :current nil)
                  (next-in-queue))))))

        (fn on-stdout [err chunk]
          (on-message :out err chunk))

        (fn on-stderr [err chunk]
          (if opts.delay-stderr-ms
            (vim.defer_fn #(on-message :err err chunk) opts.delay-stderr-ms)
            (on-message :err err chunk)))

        (fn send [code cb opts]
          (table.insert
            repl.queue
            {:code code
             :cb (if (core.get opts :batch?)
                   (let [msgs []]
                     (fn [msg]
                       (table.insert msgs msg)
                       (when msg.done?
                         (cb msgs))))
                   cb)})
          (next-in-queue)
          nil)

        (fn immediate-send [code]
          (stdin:write code)
          nil)

        (fn send-signal [signal]
          (uv.process_kill repl.handle signal)
          nil)

        (let [(handle pid-or-err)
              (uv.spawn cmd {:stdio [stdin stdout stderr]
                             :args args
                             :env (extend-env
                                    (core.merge!
                                      ;; Trying to disable custom readline config.
                                      ;; Doesn't work in practice but is probably close?
                                      ;; If you know how, please open a PR!
                                      {:INPUTRC "/dev/null"
                                       :TERM "dumb"}
                                      opts.env))}
                        (client.schedule-wrap on-exit))]
          (if handle
            (do
              (stdout:read_start (client.schedule-wrap on-stdout))
              (stderr:read_start (client.schedule-wrap on-stderr))
              (client.schedule #(opts.on-success))
              (core.merge!
                repl
                {:handle handle
                 :pid pid-or-err
                 :send send
                 :immediate-send immediate-send
                 :opts opts
                 :send-signal send-signal
                 :destroy destroy}))
            (do
              (client.schedule #(opts.on-error pid-or-err))
              (destroy))))))))

M
