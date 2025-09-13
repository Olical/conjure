(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local process (autoload :conjure.process))
(local state (autoload :conjure.client.clojure.nrepl.state))

(local M (define :conjure.client.clojure.nrepl.auto-repl))

(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(fn M.enportify [subject]
  "Given a string `subject`, look for `$port` and if there randomly search
  until we find an open port. Then return a table containing the subject with
  `$port` replaced by the found port and the port number itself. If there was
  no `$port` then it'll just return a table containing the subject on it's own."
  (if (subject:find "$port")
    (let [server (vim.fn.serverstart "localhost:0")
          _ (vim.fn.serverstop server)
          port (server:gsub "localhost:" "")]
      {:subject (subject:gsub "$port" port)
       :port port})
    {:subject subject}))

(fn M.delete-auto-repl-port-file []
  (let [port-file (cfg [:connection :auto_repl :port_file])
        port (state.get :auto-repl-port)]
    (when (and port-file port (= (core.slurp port-file) port))
      (vim.fn.delete port-file))))

(fn M.upsert-auto-repl-proc []
  "Starts the auto REPL if executable and not already running."
  (let [{:subject cmd : port} (M.enportify (cfg [:connection :auto_repl :cmd]))
        port-file (cfg [:connection :auto_repl :port_file])
        enabled? (cfg [:connection :auto_repl :enabled])
        hidden? (cfg [:connection :auto_repl :hidden])]

    (when (and enabled?
               (not (process.running? (state.get :auto-repl-proc)))
               (process.executable? cmd))

      (let [proc (process.execute
                   cmd
                   {:hidden? hidden?
                    :on-exit (client.wrap M.delete-auto-repl-port-file)})]

        (core.assoc (state.get) :auto-repl-proc proc)
        (core.assoc (state.get) :auto-repl-port port)

        (when (and port-file port)
          (core.spit port-file port))
        (log.append [(.. "; Starting auto-repl: " cmd)])
        proc))))

M
