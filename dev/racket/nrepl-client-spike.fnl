(module conjure.client.racket.nrepl
  {require {a conjure.aniseed.core
            mapping conjure.mapping
            text conjure.text
            log conjure.log
            config conjure.config
            client conjure.client
            nrepl conjure.remote.nrepl}})

;; This kind of works for basic evaluations.
;; It doesn't give us access to stdio and xrepl.

(def buf-suffix ".rkt")
(def comment-prefix "; ")

(config.merge
  {:client
   {:racket
    {:nrepl
     {:connection {:default_host "127.0.0.1"
                   :default_port "7888"}
      :mapping {:connect "cc"
                :disconnect "cd"}}}}})

(defn cfg [...]
  (config.get-in [:client :racket :nrepl ...]))

(defonce- state (client.new-state #(do {:conn nil})))

(defn- with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append [(.. comment-prefix "No connection")]))))

(defn- connected? []
  (if (state :conn)
    true
    false))

(defn- display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append
        [(.. comment-prefix conn.host ":" conn.port " (" status ")")]
        {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state) :conn nil))))

(defn- send [msg cb]
  (with-conn-or-warn
    (fn [conn]
      (conn.send msg cb))))

(defn display-result [resp]
  (let [s (or resp.value resp.ex)]
    (when (a.string? s)
      (log.append (text.split-lines s)))))

;; Used for Fennel nREPL.
; (defn- ensure-session [cb]
;   (fn assume-first-session [sessions]
;     (print "ASSUMING" (a.first sessions) (a.count sessions))
;     (a.assoc (state :conn) :session (a.first sessions)))

;   (send {:op :ls-sessions}
;         (fn [msg]
;           (let [sessions msg.sessions]
;             (if (a.empty? sessions)
;               (send {:op :clone}
;                     (fn [msg]
;                       (assume-first-session [msg.new-session])))
;               (assume-first-session sessions))))))

(defn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (cfg :connection :default_host))
        port (or opts.port (cfg :connection :default_port))]

    (when (state :conn)
      (disconnect))

    (a.assoc
      (state) :conn
      (a.merge!
        (nrepl.connect
          {:host host
           :port port

           :on-failure
           (fn [err]
             (display-conn-status err)
             (disconnect))

           :on-success
           (fn []
             (send {:op :eval :code "(require xrepl)"} (fn []))
             (display-conn-status :connected))

           :on-error
           (fn [err]
             (if err
               (display-conn-status err)
               (disconnect)))

           :on-message
           (fn [msg]
             nil)

           :default-callback
           (fn [result]
             (display-result result))})

        {:seen-ns {}}))))

(defn- try-ensure-conn []
  (when (not (connected?))
    (connect)))

(defn- eval-cb-fn [opts]
  (fn [resp]
    (when (and (a.get opts :on-result)
               (a.get resp :value))
      (opts.on-result resp.value))

    (let [cb (a.get opts :cb)]
      (if cb
        (cb resp)
        (when (not opts.passive?)
          (display-result resp))))))

(defn eval-str [opts]
  (try-ensure-conn)
  (send
    {:op :eval
     :code opts.code}
    (eval-cb-fn opts)))

(defn doc-str [opts]
  (try-ensure-conn)
  (eval-str (a.update opts :code (fn [s] (.. ",doc " s)))))

(defn eval-file [opts]
  (try-ensure-conn)
  (eval-str (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(defn on-filetype []
  (mapping.buf2
    :RktDisconnect (cfg :mapping :disconnect)
    disconnect
    {:desc "Disconnect from the REPL"})

  (mapping.buf2
    :RktConnect (cfg :mapping :connect)
    #(connect)
    {:desc "Connect to a REPL"}))

(defn on-load []
  (connect))
