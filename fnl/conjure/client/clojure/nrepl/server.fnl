(module conjure.client.clojure.nrepl.server
  {require {a conjure.aniseed.core
            uuid conjure.uuid
            net conjure.net
            extract conjure.extract
            log conjure.log
            client conjure.client
            str conjure.aniseed.string
            bencode conjure.bencode
            bencode-stream conjure.bencode-stream
            config conjure.config
            ui conjure.client.clojure.nrepl.ui
            state conjure.client.clojure.nrepl.state}})

(defn with-conn-or-warn [f opts]
  (let [conn (state.get :conn)]
    (if conn
      (f conn)
      (do
        (when (not (a.get opts :silent?))
          (log.append ["; No connection"]))
        (when (a.get opts :else)
          (opts.else))))))

(defn send [msg cb]
  (let [conn (state.get :conn)]
    (when conn
      (let [msg-id (uuid.v4)]
        (a.assoc msg :id msg-id)
        (log.dbg "send" msg)
        (a.assoc-in conn [:msgs msg-id]
                    {:msg msg
                     :cb (or cb (fn []))
                     :sent-at (os.time)})
        (conn.sock:write (bencode.encode msg))
        nil))))

(defn- display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append [(.. "; " conn.host ":" conn.port " (" status ")")]
                  {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state.get) :conn nil))))

(defn with-all-msgs-fn [cb]
  (let [acc []]
    (fn [msg]
      (table.insert acc msg)
      (when msg.status.done
        (cb acc)))))

(defn close-session [session cb]
  (send
    {:op :close :session (a.get session :id)}
    cb))

(defn assume-session [session]
  (a.assoc (state.get :conn) :session (a.get session :id))
  (log.append [(.. "; Assumed session: " (session.str))]
              {:break? true}))

(defn eval [opts cb]
  (with-conn-or-warn
    (fn [_]
      (send
        {:op :eval
         :ns opts.context
         :code opts.code
         :file opts.file-path
         :line (a.get-in opts [:range :start 1])
         :column (-?> (a.get-in opts [:range :start 2]) (a.inc))
         :session (or opts.session (state.get :conn :session))

         :nrepl.middleware.print/options
         {:associative-table? 1
          :level (or (config.get-in [:client :clojure :nrepl :eval :print_options :level])
                     nil)
          :length (or (config.get-in [:client :clojure :nrepl :eval :print_options :length])
                      nil)}

         :nrepl.middleware.print/quota
         (config.get-in [:client :clojure :nrepl :eval :print_quota])

         :nrepl.middleware.print/print
         (when (config.get-in [:client :clojure :nrepl :eval :pretty_print])
           (config.get-in [:client :clojure :nrepl :eval :print_function]))}
        cb))))

(defn- with-session-ids [cb]
  (with-conn-or-warn
    (fn [_]
      (send
        {:op :ls-sessions}
        (fn [msg]
          (let [sessions (->> (a.get msg :sessions)
                              (a.filter
                                (fn [session]
                                  (not= msg.session session))))]
            (table.sort sessions)
            (cb sessions)))))))

(defn pretty-session-type [st]
  (a.get
    {:clj :Clojure
     :cljs :ClojureScript
     :cljr :ClojureCLR
     :unknown :Unknown}
    st
    (if (a.string? st)
      (.. st "?")
      "no env")))

(defn session-type [id cb]
  (send
    {:op :eval
     :code (.. "#?("
               (str.join
                 " "
                 [":clj 'clj"
                  ":cljs 'cljs"
                  ":cljr 'cljr"
                  ":default 'unknown"])
               ")")
     :session id}
    (with-all-msgs-fn
      (fn [msgs]
        (let [st (a.some #(a.get $1 :value) msgs)]
          (cb (when st (str.trim st))))))))

(defn enrich-session-id [id cb]
  (session-type
    id
    (fn [st]
      (let [t {:id id
               :type st
               :pretty-type (pretty-session-type st)
               :name (uuid.pretty id)}]
        (a.assoc t :str #(.. t.name " (" t.pretty-type ")"))
        (cb t)))))

(defn with-sessions [cb]
  (with-session-ids
    (fn [sess-ids]
      (let [rich []
            total (a.count sess-ids)]
        (if (= 0 total)
          (cb [])
          (a.run!
            (fn [id]
              (enrich-session-id
                id
                (fn [t]
                  (table.insert rich t)
                  (when (= total (a.count rich))
                    (table.sort
                      rich
                      #(< (a.get $1 :name)
                          (a.get $2 :name)))
                    (cb rich)))))
            sess-ids))))))

(defn clone-session [session]
  (send
    {:op :clone
     :session (a.get session :id)}
    (with-all-msgs-fn
      (fn [msgs]
        (enrich-session-id
          (a.some #(a.get $1 :new-session) msgs)
          assume-session)))))

(defn assume-or-create-session []
  (with-sessions
    (fn [sessions]
      (if (a.empty? sessions)
        (clone-session)
        (assume-session (a.first sessions))))))

(defn- enrich-status [msg]
  (let [ks (a.get msg :status)
        status {}]
    (a.run!
      (fn [k]
        (a.assoc status k true))
      ks)
    (a.assoc msg :status status)
    msg))

(defn- process-message [err chunk]
  (let [conn (state.get :conn)]
    (if
      err (display-conn-status err)
      (not chunk) (disconnect)
      (->> (bencode-stream.decode-all (state.get :bs) chunk)
           (a.run!
             (fn [msg]
               (log.dbg "receive" msg)
               (enrich-status msg)

               (when msg.status.need-input
                 (client.schedule
                   (fn []
                     (send {:op :stdin
                            :stdin (.. (or (extract.prompt "Input required: ")
                                           "")
                                       "\n")
                            :session conn.session}))))

               (let [cb (a.get-in conn [:msgs msg.id :cb] #(ui.display-result $1))
                     (ok? err) (pcall cb msg)]
                 (when (not ok?)
                   (log.append [(.. "; conjure.client.clojure.nrepl error: " err)]))
                 (when msg.status.unknown-session
                   (log.append ["; Unknown session, correcting"])
                   (assume-or-create-session))
                 (when msg.status.namespace-not-found
                   (log.append [(.. "; Namespace not found: " msg.ns)]))
                 (when msg.status.done
                   (a.assoc-in conn [:msgs msg.id] nil)))))))))

(defn- process-message-queue []
  (a.assoc (state.get) :awaiting-process? false)
  (when (not (a.empty? (state.get :message-queue)))
    (let [msgs (state.get :message-queue)]
      (a.assoc (state.get) :message-queue [])
      (a.run!
        (fn [args]
          (process-message (unpack args)))
        msgs))))

(defn- enqueue-message [...]
  (table.insert (state.get :message-queue) [...])
  (when (not (state.get :awaiting-process?))
    (a.assoc (state.get) :awaiting-process? true)
    (client.schedule process-message-queue)))

(defn- eval-preamble [cb]
  (send
    {:op :eval
     :code (.. "(ns conjure.internal"
               "  (:require [clojure.pprint :as pp]))"
               "(defn pprint [val w opts]"
               "  (apply pp/write val"
               "    (mapcat identity (assoc opts :stream w))))")}
    (when cb
      (with-all-msgs-fn cb))))

(defn- capture-describe []
  (send
    {:op :describe}
    (fn [msg]
      (a.assoc (state.get :conn) :describe msg))))

(defn with-conn-and-op-or-warn [op f opts]
  (with-conn-or-warn
    (fn [conn]
      (if (a.get-in conn [:describe :ops op])
        (f conn)
        (do
          (when (not (a.get opts :silent?))
            (log.append
              [(.. "; Unsupported operation: " op)
               "; Ensure the CIDER middleware is installed and up to date"
               "; https://docs.cider.mx/cider-nrepl/usage.html"]))
          (when (a.get opts :else)
            (opts.else)))))
    opts))

(defn- handle-connect-fn [cb]
  (client.schedule-wrap
    (fn [err]
      (let [conn (state.get :conn)]
        (if err
          (do
            (display-conn-status err)
            (disconnect))

          (do
            (conn.sock:read_start (client.wrap enqueue-message))
            (display-conn-status :connected)
            (capture-describe)
            (assume-or-create-session)
            (eval-preamble cb)))))))

(defn connect [{: host : port : cb}]
  (when (state.get :conn)
    (disconnect))

  (a.assoc
    (state.get) :conn
    (a.merge
      (net.connect
        {:host host
         :port port
         :cb (handle-connect-fn cb)})
      {:msgs {}
       :seen-ns {}
       :session nil})))
