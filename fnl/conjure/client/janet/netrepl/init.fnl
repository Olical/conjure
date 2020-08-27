(module conjure.client.janet.netrepl
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            bridge conjure.bridge
            mapping conjure.mapping
            text conjure.text
            log conjure.log
            config conjure.config
            server conjure.client.janet.netrepl.server}})

(def buf-suffix ".janet")
(def comment-prefix "# ")

(config.merge
  {:client
   {:janet
    {:netrepl
     {:connection {:default_host "127.0.0.1"
                   :default_port "9365"}
      :mapping {:connect "cc"
                :disconnect "cd"}}}}})

(defn connect [opts]
  (server.connect opts))

(defn- try-ensure-conn []
  (when (not (server.connected?))
    (connect {:silent? true})))

(defn eval-str [opts]
  (try-ensure-conn)
  (server.send
    (.. opts.code "\n")
    (fn [msg]
      (let [clean (text.trim-last-newline msg)]
        (when opts.on-result
          ;; ANSI escape trimming happens here AND in log append (if enabled)
          ;; so that "eval and replace form" won't end up inserting ANSI codes.
          (opts.on-result (text.strip-ansi-escape-sequences clean)))
        (when (not opts.passive?)
          (log.append (text.split-lines clean)))))))

(defn doc-str [opts]
  (try-ensure-conn)
  (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

(defn eval-file [opts]
  (try-ensure-conn)
  (eval-str
    (a.assoc opts :code (.. "(do (dofile \"" opts.file-path
                            "\" :env (fiber/getenv (fiber/current))) nil)"))))

(defn on-filetype []
  (mapping.buf :n (config.get-in [:client :janet :netrepl :mapping :disconnect])
               :conjure.client.janet.netrepl.server :disconnect)
  (mapping.buf :n (config.get-in [:client :janet :netrepl :mapping :connect])
               :conjure.client.janet.netrepl.server :connect))

(defn on-load []
  (server.connect {}))
