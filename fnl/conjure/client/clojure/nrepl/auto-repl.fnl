(module conjure.client.clojure.nrepl.auto-repl
  {autoload {str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             process conjure.process
             log conjure.log
             config conjure.config
             client conjure.client
             state conjure.client.clojure.nrepl.state}})

(def- cfg (config.get-in-fn [:client :clojure :nrepl]))

(defn enportify [subject]
  "Given a string `subject`, look for `$port` and if there randomly search
  until we find an open port. Then return a table containing the subject with
  `$port` replaced by the found port and the port number itself. If there was
  no `$port` then it'll just return a table containing the subject on it's own."
  (if (subject:find "$port")
    (let [server (nvim.fn.serverstart "localhost:0")
          _ (nvim.fn.serverstop server)
          port (server:gsub "localhost:" "")]
      {:subject (subject:gsub "$port" port)
       :port port})
    {:subject subject}))

(defn delete-auto-repl-port-file []
  (let [port-file (cfg [:connection :auto_repl :port_file])
        port (state.get :auto-repl-port)]
    (when (and port-file port (= (a.slurp port-file) port))
      (nvim.fn.delete port-file))))

(defn upsert-auto-repl-proc []
  "Starts the auto REPL if executable and not already running."
  (let [{:subject cmd : port} (enportify (cfg [:connection :auto_repl :cmd]))
        port-file (cfg [:connection :auto_repl :port_file])
        enabled? (cfg [:connection :auto_repl :enabled])
        hidden? (cfg [:connection :auto_repl :hidden])]

    (when (and enabled?
               (not (process.running? (state.get :auto-repl-proc)))
               (process.executable? cmd))

      (let [proc (process.execute
                   cmd
                   {:hidden? hidden?
                    :on-exit (client.wrap delete-auto-repl-port-file)})]

        (a.assoc (state.get) :auto-repl-proc proc)
        (a.assoc (state.get) :auto-repl-port port)

        (when (and port-file port)
          (a.spit port-file port))
        (log.append [(.. "; Starting auto-repl: " cmd)])
        proc))))
