(local autoload (require :nfnl.autoload))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local debugger (autoload :conjure.client.clojure.nrepl.debugger))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local nrepl (autoload :conjure.remote.nrepl))
(local state (autoload :conjure.client.clojure.nrepl.state))
(local str (autoload :conjure.aniseed.string))
(local timer (autoload :conjure.timer))
(local ui (autoload :conjure.client.clojure.nrepl.ui))
(local uuid (autoload :conjure.uuid))

(fn with-conn-or-warn [f opts]
  (let [conn (state.get :conn)]
    (if conn
      (f conn)
      (do
        (when (not (a.get opts :silent?))
          (log.append ["; No connection"]))
        (when (a.get opts :else)
          (opts.else))))))

(fn connected? []
  (if (state.get :conn)
    true
    false))

(fn send [msg cb]
  (with-conn-or-warn
    (fn [conn]
      (conn.send msg cb))))

(fn display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append [(str.join
                     ["; " conn.host ":" conn.port " (" status ")"
                      (when conn.port_file_path
                        (str.join [": " conn.port_file_path]))])]
                  {:break? true}))))

(fn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state.get) :conn nil))))

(fn close-session [session cb]
  (send
    {:op :close :session (a.get session :id)}
    cb))

(fn assume-session [session]
  (a.assoc (state.get :conn) :session (a.get session :id))
  (log.append [(str.join ["; Assumed session: " (session.str)])]
              {:break? true}))

(fn un-comment [code]
  (when code
    (string.gsub code "^#_" "")))

(fn eval [opts cb]
  (with-conn-or-warn
    (fn [_]
      (send
        {:op :eval
         :ns opts.context
         :code (un-comment opts.code)
         :file opts.file-path
         :line (a.get-in opts [:range :start 1])
         :column (-?> (a.get-in opts [:range :start 2]) (a.inc))
         :session opts.session

         :nrepl.middleware.print/options
         {;; This forces this table to remain associative even if level and length aren't set.
          ;; If you have an empty table in Fennel / Lua like {} it actually becomes sequential by default.
          ;; So it's as if we set the options to [] which is _not_ good.
          :associative 1

          :level
          (or
            (config.get-in [:client :clojure :nrepl :eval :print_options :level])
            nil)

          :length
          (or
            (config.get-in [:client :clojure :nrepl :eval :print_options :length])
            nil)

          :right-margin
          (or
            (config.get-in [:client :clojure :nrepl :eval :print_options :right_margin])
            nil)}

         :nrepl.middleware.print/quota
         (config.get-in [:client :clojure :nrepl :eval :print_quota])

         :nrepl.middleware.print/buffer-size
         (config.get-in [:client :clojure :nrepl :eval :print_buffer_size])

         :nrepl.middleware.print/print
         (when (config.get-in [:client :clojure :nrepl :eval :pretty_print])
           (config.get-in [:client :clojure :nrepl :eval :print_function]))}
        cb))))

(fn with-session-ids [cb]
  (with-conn-or-warn
    (fn [_]
      (send
        {:op :ls-sessions
         :session :no-session}
        (fn [msg]
          (let [sessions (a.get msg :sessions)]
            (when (= :table (type sessions))
              (table.sort sessions))
            (cb sessions)))))))

(fn pretty-session-type [st]
  (a.get
    {:clj :Clojure
     :cljs :ClojureScript
     :cljr :ClojureCLR}
    st
    "Unknown https://github.com/Olical/conjure/wiki/Frequently-asked-questions#what-does-unknown-mean-in-the-log-when-connecting-to-a-clojure-nrepl"))

(fn session-type [id cb]
  (let [state {:done? false}]

    ;; Let's not wait forever just to check the type of a session.
    ;; This prevents long running processes preventing session hopping.
    ;; https://github.com/Olical/conjure/issues/366
    (timer.defer
      (fn []
        (when (not state.done?)
          (set state.done? true)
          (cb :unknown)))

      ;; Hard coding this because it shouldn't matter too much.
      200)

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
          (let [st (a.some #(a.get $1 :value) msgs)]
            (when (not state.done?)
              (set state.done? true)
              (cb (when st (str.trim st))))))))))

(fn enrich-session-id [id cb]
  (session-type
    id
    (fn [st]
      (let [t {:id id
               :type st
               :pretty-type (pretty-session-type st)
               :name (uuid.pretty id)}]
        (a.assoc t :str #(str.join [t.name " (" t.pretty-type ")"]))
        (cb t)))))

(fn with-sessions [cb]
  (with-session-ids
    (fn [sess-ids]
      (let [rich []
            total (a.count sess-ids)]
        (if (= 0 total)
          (cb [])
          (a.run!
            (fn [id]
              (log.dbg "with-sessions id for enrichment" id)
              (when id
                (enrich-session-id
                  id
                  (fn [t]
                    (table.insert rich t)
                    (when (= total (a.count rich))
                      (table.sort
                        rich
                        #(< (a.get $1 :name)
                            (a.get $2 :name)))
                      (cb rich))))))
            sess-ids))))))

(fn clone-session [session]
  (send
    {:op :clone
     :session (a.get session :id)}
    (nrepl.with-all-msgs-fn
      (fn [msgs]
        (let [session-id (a.some #(a.get $1 :new-session) msgs)]
          (log.dbg "clone-session id for enrichment" id)
          (when session-id
            (enrich-session-id session-id assume-session)))))))

(fn assume-or-create-session []
  (a.assoc (state.get :conn) :session nil)
  (with-sessions
    (fn [sessions]
      (if (a.empty? sessions)
        (clone-session)
        (assume-session (a.first sessions))))))

(fn eval-preamble [cb]
  (let [queue-size (config.get-in [:client :clojure :nrepl :tap :queue_size])]
    (send
      {:op :eval
       :code (str.join
               "\n"
               ["(create-ns 'conjure.internal)"
                 "(intern 'conjure.internal 'initial-ns (symbol (str *ns*)))"

                 "(ns conjure.internal"
                 "  (:require [clojure.pprint :as pp] [clojure.test] [clojure.data] [clojure.string]))"

                 "(defn pprint [val w opts]"
                 "  (apply pp/write val"
                 "    (mapcat identity (assoc opts :stream w))))"

                 "(defn bounded-conj [queue x limit]"
                 "  (->> x (conj queue) (take limit)))"

                 (.. "(def tap-queue-size " queue-size ")")
                 "(defonce tap-queue! (atom (list)))"

                 ;; Must be a defonce so that we always have the same function
                 ;; reference to remove-tap and add-tap. If we make a new
                 ;; function each time we'll end up adding more and more tap
                 ;; functions.
                 "(defonce enqueue-tap!"
                 "  (fn [x] (swap! tap-queue! bounded-conj x tap-queue-size)))"

                 ;; No setup for older Clojure versions.
                 "(when (resolve 'add-tap)"
                 "  (remove-tap enqueue-tap!)"
                 "  (add-tap enqueue-tap!))"

                 "(defn dump-tap-queue! []"
                 "  (reverse (first (reset-vals! tap-queue! (list)))))"

                 "(defmethod clojure.test/report :fail [m]"
                 "  (clojure.test/with-test-out"
                 "    (clojure.test/inc-report-counter :fail)"
                 "    (println \"\nFAIL in\" (clojure.test/testing-vars-str m))"
                 "    (when (seq clojure.test/*testing-contexts*) (println (clojure.test/testing-contexts-str)))"
                 "    (when-let [message (:message m)] (println message))"
                 "    (print \"expected:\" (with-out-str (prn (:expected m))))"
                 "    (print \"  actual:\" (with-out-str (prn (:actual m))))"
                 "    (when (and (seq? (:actual m))"
                 "               (= #'clojure.core/not (resolve (first (:actual m))))"
                 "               (seq? (second (:actual m)))"
                 "               (= #'clojure.core/= (resolve (first (second (:actual m)))))"
                 "               (= 3 (count (second (:actual m)))))"
                 "      (let [[missing extra _] (clojure.data/diff (second (second (:actual m))) (last (second (:actual m))))"
                 "            missing-str (with-out-str (pp/pprint missing))"
                 "            missing-lines (clojure.string/split-lines missing-str)"
                 "            extra-str (with-out-str (pp/pprint extra))"
                 "            extra-lines (clojure.string/split-lines extra-str)]"
                 "        (when (some? missing) (doseq [m missing-lines] (println \"- \" m)))"
                 "        (when (some? extra) (doseq [e extra-lines] (println \"+ \" e)))))))"

                 "(in-ns initial-ns)"])}
      (when cb
        (nrepl.with-all-msgs-fn cb)))))

(fn capture-describe []
  (send
    {:op :describe}
    (fn [msg]
      (a.assoc (state.get :conn) :describe msg))))

(fn with-conn-and-ops-or-warn [op-names f opts]
  "Takes a sequential table of op names and calls your function f with an
  associative table of the shape {:op-name true} if any exist. If not, your
  function is not called and a warning is displayed."
  (with-conn-or-warn
    (fn [conn]
      (let [found-ops
            (a.reduce
              (fn [acc op]
                (if (a.get-in conn [:describe :ops op])
                  (a.assoc acc op true)
                  acc))
              {}
              op-names)]

        (if (not (a.empty? found-ops))
          (f conn found-ops)
          (do
            (when (not (a.get opts :silent?))
              (log.append
                ["; None of the required operations are supported by this nREPL."
                 "; Ensure your nREPL is up to date."
                 "; Consider installing or updating the CIDER middleware."
                 "; https://docs.cider.mx/cider-nrepl/usage.html"]))
            (when (a.get opts :else)
              (opts.else))))))
    opts))

(fn handle-input-request [msg]
  (send
    {:op :stdin
     :stdin (.. (or (extract.prompt "Input required: ")
                    "")
                "\n")
     :session msg.session}))

(fn connect [{: host : port : cb : port_file_path : connect-opts}]
  (when (state.get :conn)
    (disconnect))

  (a.assoc
    (state.get) :conn
    (a.merge!
      (nrepl.connect
        (a.merge
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
               (log.append [(str.join ["; Namespace not found: " msg.ns])])))

           :side-effect-callback
           (fn [msg]
             (when msg.status.need-input
               (client.schedule handle-input-request msg))

             (when msg.status.need-debug-input
               (client.schedule debugger.handle-input-request msg)))

           :default-callback
           (fn [msg]
             (ui.display-result msg))}

          connect-opts))

      {:seen-ns {}
       :port_file_path port_file_path})))

{: assume-or-create-session
 : assume-session
 : clone-session
 : close-session
 : connect
 : connected?
 : disconnect
 : enrich-session-id
 : eval
 : handle-input-request
 : pretty-session-type
 : send
 : session-type
 : un-comment
 : with-conn-and-ops-or-warn
 : with-conn-or-warn
 : with-sessions}
