(module conjure.client.clojure.nrepl.server
  {require {a conjure.aniseed.core
            uuid conjure.uuid
            timer conjure.timer
            log conjure.log
            str conjure.aniseed.string
            config conjure.config
            ui conjure.client.clojure.nrepl.ui
            state conjure.client.clojure.nrepl.state
            nrepl conjure.remote.nrepl}})

(defn with-conn-or-warn [f opts]
  (let [conn (state.get :conn)]
    (if conn
      (f conn)
      (do
        (when (not (a.get opts :silent?))
          (log.append ["; No connection"]))
        (when (a.get opts :else)
          (opts.else))))))

(defn connected? []
  (if (state.get :conn)
    true
    false))

(defn send [msg cb]
  (with-conn-or-warn
    (fn [conn]
      (conn.send msg cb))))

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
         :session opts.session

         :nrepl.middleware.print/options
         {;; This forces this table to remain associative even if level and length aren't set.
          ;; If you have an empty table in Fennel / Lua like {} it actually becomes sequential by default.
          ;; So it's as if we set the options to [] which is _not_ good.
          :associative 1

          :level (or (config.get-in [:client :clojure :nrepl :eval :print_options :level])
                     nil)
          :length (or (config.get-in [:client :clojure :nrepl :eval :print_options :length])
                      nil)}

         :nrepl.middleware.print/quota
         (config.get-in [:client :clojure :nrepl :eval :print_quota])

         :nrepl.middleware.print/buffer-size
         (config.get-in [:client :clojure :nrepl :eval :print_buffer_size])

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
     :unknown :Unknown
     :timeout :Timeout}
    st
    (if (a.string? st)
      (.. st "?")
      "https://conjure.fun/no-env")))

(defn session-type [id cb]
  (let [timeout (timer.defer #(cb :timeout) 300)]
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
      (nrepl.with-all-msgs-fn
        (fn [msgs]
          (timer.destroy timeout)
          (let [st (a.some #(a.get $1 :value) msgs)]
            (cb (when st (str.trim st)))))))))

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
    (nrepl.with-all-msgs-fn
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

(defn- eval-preamble [cb]
  (send
    {:op :eval
     :code (.. "(ns conjure.internal"
               "  (:require [clojure.pprint :as pp]))"
               "(defn pprint [val w opts]"
               "  (apply pp/write val"
               "    (mapcat identity (assoc opts :stream w))))")}
    (when cb
      (nrepl.with-all-msgs-fn cb))))

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

(defn connect [{: host : port : cb}]
  (when (state.get :conn)
    (disconnect))

  (a.assoc
    (state.get) :conn
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
           (display-conn-status :connected)
           (capture-describe)
           (assume-or-create-session)
           (eval-preamble cb))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (disconnect)))

         :on-message
         (fn [msg]
           (when msg.status.unknown-session
             (log.append ["; Unknown session, correcting"])
             (assume-or-create-session))
           (when msg.status.namespace-not-found
             (log.append [(.. "; Namespace not found: " msg.ns)])))

         :default-callback
         (fn [result]
           (ui.display-result result))})

      {:seen-ns {}})))
