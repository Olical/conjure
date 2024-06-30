(module conjure.client.guile.nrepl
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             mapping conjure.mapping
             eval conjure.eval
             str conjure.aniseed.string
             text conjure.text
             config conjure.config
             client conjure.client
             util conjure.util
             ts conjure.tree-sitter}})

(config.merge
  {:client
   {:guile
    {:nrepl
     {:default_host "localhost"
      :port_files [".nrepl-port"]}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:guile
      {:nrepl
       {:mapping {:disconnect "cd"
                  :connect_port_file "cf"
                  :interrupt "ei"}}}}}))

(def- cfg (config.get-in-fn [:client :guile :nrepl]))

(defonce- state (client.new-state #(do {:repl nil})))

(def buf-suffix ".scm")
(def comment-prefix "; ")
(def context-pattern "%(define%-module%s+(%([%g%s]-%))")
(def form-node? ts.node-surrounded-by-form-pair-chars?)
(def comment-node? ts.lisp-comment-node?)
(defn symbol-node? [node]
  (string.find (node:type) :kwd))

(defn context [header]
  (-?> header
       (parse.strip-shebang)
       (parse.strip-meta)
       (parse.strip-comments)
       (string.match "%(%s*ns%s+([^)]*)")
       (str.split "%s+")
       (a.first)))

(defn eval-file [opts]
  (eval-file opts))

(defn eval-str [opts]
  (eval-str opts))

(defn doc-str [opts]
  (doc-str opts))

(defn def-str [opts]
  (def-str opts))

(defn connect [opts]
  (connect-host-port opts))

(defn on-filetype []
  (mapping.buf
    :GuileDisconnect (cfg [:mapping :disconnect])
    (util.wrap-require-fn-call :conjure.client.guile.nrepl :disconnect)
    {:desc "Disconnect from the current nREPL"})

  (mapping.buf
    :GuileConnectPortFile (cfg [:mapping :connect_port_file])
    (util.wrap-require-fn-call :conjure.client.guile.nrepl :connect-port-file)
    {:desc "Connect to port specified in .nrepl-port"})

  (mapping.buf
    :GuileInterrupt (cfg [:mapping :interrupt])
    (util.wrap-require-fn-call :conjure.client.guile.nrepl :interrupt)
    {:desc "Interrupt the current evaluation"}))

(defn on-load []
  (connect-port-file))

(defn on-exit []
  (disconnect))
