(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local debugger (autoload :conjure.client.clojure.nrepl.debugger))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local nrepl (autoload :conjure.remote.nrepl))
(local state (autoload :conjure.client.clojure.nrepl.state))
(local str (autoload :conjure.nfnl.string))
(local timer (autoload :conjure.timer))
(local ui (autoload :conjure.client.clojure.nrepl.ui))
(local uuid (autoload :conjure.uuid))
(local fs (autoload :conjure.nfnl.fs))

(local M (define :conjure.client.clojure.nrepl.server))

(fn M.with-conn-or-warn [f opts]
  (let [conn (state.get :conn)]
    (if conn
      (f conn)
      (do
        (when (not (core.get opts :silent?))
          (log.append ["; No connection"]))
        (when (core.get opts :else)
          (opts.else))))))

(fn M.connected? []
  (if (state.get :conn)
    true
    false))

(fn M.send [msg cb]
  (M.with-conn-or-warn
    (fn [conn]
      (conn.send msg cb))))

(fn display-conn-status [status]
  (M.with-conn-or-warn
    (fn [conn]
      (log.append [(str.join
                     ["; " conn.host ":" conn.port " (" status ")"
                      (when conn.port_file_path
                        (str.join [": " conn.port_file_path]))])]
                  {:break? true}))))

(fn M.disconnect []
  (M.with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (core.assoc (state.get) :conn nil))))

(fn M.close-session [session cb]
  (M.send
    {:op :close :session (core.get session :id)}
    cb))

(fn M.assume-session [session]
  (core.assoc (state.get :conn) :session (core.get session :id))
  (log.append [(str.join ["; Assumed session: " (session.str)])]
              {:break? true}))

(fn M.un-comment [code]
  (when code
    (string.gsub code "^#_" "")))

(fn print-opts []
  (let [print-fn (config.get-in [:client :clojure :nrepl :eval :print_function])]
    (when (and (config.get-in [:client :clojure :nrepl :eval :pretty_print]) print-fn)
      {:nrepl.middleware.print/print print-fn
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
       (config.get-in [:client :clojure :nrepl :eval :print_buffer_size])})))

(fn M.eval [opts cb]
  (M.with-conn-or-warn
    (fn [_]
      (M.send
        (core.merge
          {:op :eval
           :ns opts.context
           :code (M.un-comment opts.code)
           :file opts.file-path
           :line (core.get-in opts [:range :start 1])
           :column (-?> (core.get-in opts [:range :start 2]) (core.inc))
           :session opts.session}
          (print-opts))
        cb))))

(fn M.load-file [opts cb]
  (M.with-conn-or-warn
    (fn [_]
      (M.send
        (core.merge
          {:op :load-file
           :file opts.code
           :file-name (fs.filename opts.file-path)
           :file-path opts.file-path
           :session opts.session}
          (print-opts))
        cb))))

(fn with-session-ids [cb]
  (M.with-conn-or-warn
    (fn [_]
      (M.send
        {:op :ls-sessions
         :session :no-session}
        (fn [msg]
          (let [sessions (core.get msg :sessions)]
            (when (= :table (type sessions))
              (table.sort sessions))
            (cb sessions)))))))

(fn M.pretty-session-type [st]
  (core.get
    {:clj :Clojure
     :cljs :ClojureScript
     :cljr :ClojureCLR}
    st
    "Unknown https://github.com/Olical/conjure/wiki/Frequently-asked-questions#what-does-unknown-mean-in-the-log-when-connecting-to-a-clojure-nrepl"))

(fn M.session-type [id cb]
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

    (M.send
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
          (let [st (core.some #(core.get $1 :value) msgs)]
            (when (not state.done?)
              (set state.done? true)
              (cb (when st (str.trim st))))))))))

(fn M.enrich-session-id [id cb]
  (M.session-type
    id
    (fn [st]
      (let [t {:id id
               :type st
               :pretty-type (M.pretty-session-type st)
               :name (uuid.pretty id)}]
        (core.assoc t :str #(str.join [t.name " (" t.pretty-type ")"]))
        (cb t)))))

(fn M.with-sessions [cb]
  (with-session-ids
    (fn [sess-ids]
      (let [rich []
            total (core.count sess-ids)]
        (if (= 0 total)
          (cb [])
          (core.run!
            (fn [id]
              (log.dbg "with-sessions id for enrichment" id)
              (when id
                (M.enrich-session-id
                  id
                  (fn [t]
                    (table.insert rich t)
                    (when (= total (core.count rich))
                      (table.sort
                        rich
                        #(< (core.get $1 :name)
                            (core.get $2 :name)))
                      (cb rich))))))
            sess-ids))))))

(fn M.clone-session [session]
  (M.send
    {:op :clone
     :session (core.get session :id)
     :client-name "Conjure"}
    (nrepl.with-all-msgs-fn
      (fn [msgs]
        (let [session-id (core.some #(core.get $1 :new-session) msgs)]
          (log.dbg "clone-session id for enrichment" id)
          (when session-id
            (M.enrich-session-id session-id M.assume-session)))))))

(fn M.assume-or-create-session []
  (core.assoc (state.get :conn) :session nil)
  (M.with-sessions
    (fn [sessions]
      (if (core.empty? sessions)
        (M.clone-session)
        (M.assume-session (core.first sessions))))))

(fn eval-preamble [cb]
  (let [queue-size (config.get-in [:client :clojure :nrepl :tap :queue_size])
        pretty-print-test-failures? (config.get-in [:client :clojure :nrepl :test :pretty_print_test_failures])]
    (M.send
      {:op :eval
       :code (str.join
               "\n"
               (core.concat
                 ["(create-ns 'conjure.internal)"
                   "(intern 'conjure.internal 'initial-ns (symbol (str *ns*)))"

                   "(ns conjure.internal"
                   "  (:require [clojure.pprint :as pp] [clojure.test] [clojure.data] [clojure.string]))"

                   ;; This is a shim that inserts a pprint fn in the place that CIDER would create it if it's not found.
                   ;; We shim instead of creating our own distinct function because babashka requires us
                   ;; to refer to `cider.nrepl.pprint/pprint` if we want to use pretty printing.
                   ;; https://github.com/Olical/conjure/issues/406
                   "(when-not (find-ns 'cider.nrepl.pprint)"
                   "  (create-ns 'cider.nrepl.pprint)"
                   "  (intern 'cider.nrepl.pprint 'pprint"
                   "    (fn pprint [val w opts]"
                   "      (apply pp/write val"
                   "        (mapcat identity (assoc opts :stream w))))))"

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
                   "  (reverse (first (reset-vals! tap-queue! (list)))))"]
                 (when pretty-print-test-failures?
                   ["(defmethod clojure.test/report :fail [m]"
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
                    "        (when (some? extra) (doseq [e extra-lines] (println \"+ \" e)))))))"])

                   ["(in-ns initial-ns)"]))}
      (when cb
        (nrepl.with-all-msgs-fn cb)))))

(fn capture-describe []
  (M.send
    {:op :describe}
    (fn [msg]
      (core.assoc (state.get :conn) :describe msg))))

(fn M.with-conn-and-ops-or-warn [op-names f opts]
  "Takes a sequential table of op names and calls your function f with an
  associative table of the shape {:op-name true} if any exist. If not, your
  function is not called and a warning is displayed."
  (M.with-conn-or-warn
    (fn [conn]
      (let [found-ops
            (core.reduce
              (fn [acc op]
                (if (core.get-in conn [:describe :ops op])
                  (core.assoc acc op true)
                  acc))
              {}
              op-names)]

        (if (not (core.empty? found-ops))
          (f conn found-ops)
          (do
            (when (not (core.get opts :silent?))
              (log.append
                ["; None of the required operations are supported by this nREPL."
                 "; Ensure your nREPL is up to date."
                 "; Consider installing or updating the CIDER middleware."
                 "; https://docs.cider.mx/cider-nrepl/usage.html"]))
            (when (core.get opts :else)
              (opts.else))))))
    opts))

(fn M.handle-input-request [msg]
  (M.send
    {:op :stdin
     :stdin (.. (or (extract.prompt "Input required: ")
                    "")
                "\n")
     :session msg.session}))

(fn M.connect [{: host : port : cb : port_file_path : connect-opts}]
  (when (state.get :conn)
    (M.disconnect))

  (core.assoc
    (state.get) :conn
    (core.merge!
      (nrepl.connect
        (core.merge
          {:host host
           :port port

           :on-failure
           (fn [err]
             (display-conn-status err)
             (M.disconnect))

           :on-success
           (fn []
             (display-conn-status :connected)
             (capture-describe)
             (M.assume-or-create-session)
             (eval-preamble cb))

           :on-error
           (fn [err]
             (if err
               (display-conn-status err)
               (M.disconnect)))

           :on-message
           (fn [msg]
             (when msg.status.unknown-session
               (log.append ["; Unknown session, correcting"])
               (M.assume-or-create-session))
             (when msg.status.namespace-not-found
               (log.append [(str.join ["; Namespace not found: " msg.ns])])))

           :side-effect-callback
           (fn [msg]
             (when msg.status.need-input
               (client.schedule M.handle-input-request msg))

             (when msg.status.need-debug-input
               (client.schedule debugger.handle-input-request msg)))

           :default-callback
           (fn [msg]
             (ui.display-result msg))}

          connect-opts))

      {:seen-ns {}
       :port_file_path port_file_path})))

M
