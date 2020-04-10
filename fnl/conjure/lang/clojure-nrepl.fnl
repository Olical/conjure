(module conjure.lang.clojure-nrepl
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            view conjure.aniseed.view
            log conjure.log
            lang conjure.lang
            text conjure.text
            extract conjure.extract
            mapping conjure.mapping
            bencode conjure.bencode
            bencode-stream conjure.bencode-stream
            eval conjure.aniseed.eval
            bridge conjure.bridge
            editor conjure.editor
            uuid conjure.uuid
            ll conjure.linked-list}})

;; TODO Split up into multiple modules.
;; TODO Refreshing of namespaces.
;; TODO Test running.
;; TODO Handle stdin requests.

(def buf-suffix ".cljc")
(def context-pattern "[(]%s*ns%s*(.-)[%s){]")
(def comment-prefix "; ")

(def config
  {:debug? false
   :interrupt {:sample-limit 0.3}
   :mappings {:disconnect "cd"
              :connect-port-file "cf"

              :interrupt "ei"
              :last-exception "ex"
              :result-1 "e1"
              :result-2 "e2"
              :result-3 "e3"
              :view-source "es"

              :session-clone "sc"
              :session-fresh "sf"
              :session-close "sq"
              :session-close-all "sQ"
              :session-list "sl"
              :session-next "sn"
              :session-prev "sp"
              :session-select "ss"
              :session-type "st"}})

(defonce- state
  {:loaded? false
   :conn nil})

(defonce- bs (bencode-stream.new))

(defn- display [lines opts]
  (lang.with-filetype :clojure log.append lines opts))

(defn- with-conn-or-warn [f]
  (let [conn (a.get state :conn)]
    (if conn
      (f conn)
      (display ["; No connection"]))))

(defn- display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (display [(.. "; " conn.host ":" conn.port " (" status ")")]
               {:break? true}))))

(defn- dbg [desc data]
  (when config.debug?
    (display (a.concat
               [(.. "; debug " desc)]
               (text.split-lines (view.serialise data)))))
  data)

(defn- send [msg cb]
  (let [conn (a.get state :conn)]
    (when conn
      (let [msg-id (uuid.v4)]
        (a.assoc msg :id msg-id)
        (dbg "->" msg)
        (a.assoc-in conn [:msgs msg-id]
                    {:msg msg
                     :cb (or cb (fn []))
                     :sent-at (os.time)})
        (conn.sock:write (bencode.encode msg))
        nil))))

(defn- status= [msg state]
  (and msg msg.status (a.some #(= state $1) msg.status)))

(defn- with-all-msgs-fn [cb]
  (let [acc []]
    (fn [msg]
      (table.insert acc msg)
      (when (status= msg :done)
        (cb acc)))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (when (not (conn.sock:is_closing))
        (conn.sock:read_stop)
        (conn.sock:shutdown)
        (conn.sock:close))
      (display-conn-status :disconnected)
      (a.assoc state :conn nil))))

(defn- display-result [opts resp]
  (let [lines (if
                resp.out (text.prefixed-lines resp.out "; (out) ")
                resp.err (text.prefixed-lines resp.err "; (err) ")
                resp.value (text.split-lines resp.value)
                nil)]
    (display lines)))

(defn- assume-session [session]
  (a.assoc-in state [:conn :session] session)
  (display [(.. "; Assumed session: " session)]
           {:break? true}))

(defn- clone-session [session]
  (send
    {:op :clone
     :session session}
    (with-all-msgs-fn
      (fn [msgs]
        (assume-session (a.get (a.last msgs) :new-session))))))

(defn- with-sessions [cb]
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

(defn- eval-str-raw [opts cb]
  (with-conn-or-warn
    (fn [_]
      (send
        {:op :eval
         :code opts.code
         :file opts.file-path
         :line (a.get-in opts [:range :start 1])
         :column (-?> (a.get-in opts [:range :start 2]) (a.inc))
         :session (a.get-in state [:conn :session])}
        cb))))

(defn display-session-type []
  (eval-str-raw
    {:code (.. "#?("
               (str.join
                 " "
                 [":clj 'Clojure"
                  ":cljs 'ClojureScript"
                  ":cljr 'ClojureCLR"
                  ":default 'Unknown"])
               ")")}
    (with-all-msgs-fn
      (fn [msgs]
        (display [(.. "; Session type: " (a.get (a.first msgs) :value))]
                 {:break? true})))))

(defn- assume-or-create-session []
  (with-sessions
    (fn [sessions]
      (if (a.empty? sessions)
        (clone-session)
        (assume-session (a.first sessions))))))

(defn- handle-read-fn []
  (vim.schedule_wrap
    (fn [err chunk]
      (let [conn (a.get state :conn)]
        (if
          err (display-conn-status err)
          (not chunk) (disconnect)
          (->> (bencode-stream.decode-all bs chunk)
               (a.run!
                 (fn [msg]
                   (dbg "<-" msg)
                   (let [cb (a.get-in conn [:msgs msg.id :cb] #(display-result nil $1))
                         (ok? err) (pcall cb msg)]
                     (when (not ok?)
                       (display [(.. "; conjure.lang.clojure-nrepl error: " err)]))
                     (when (status= msg :unknown-session)
                       (display ["; Unknown session, correcting"])
                       (assume-or-create-session))
                     (when (status= msg :done)
                       (a.assoc-in conn [:msgs msg.id] nil)))))))))))

(defn- handle-connect-fn []
  (vim.schedule_wrap
    (fn [err]
      (let [conn (a.get state :conn)]
        (if err
          (do
            (display-conn-status err)
            (disconnect))

          (do
            (conn.sock:read_start (handle-read-fn))
            (display-conn-status :connected)
            (assume-or-create-session)))))))

(defn connect [{: host : port}]
  (let [conn {:sock (vim.loop.new_tcp)
              :host host
              :port port
              :msgs {}
              :session nil}]

    (when (a.get state :conn)
      (disconnect))

    (a.assoc state :conn conn)
    (conn.sock:connect host port (handle-connect-fn))))

(defn connect-port-file []
  (let [port (-?> (a.slurp ".nrepl-port") (tonumber))]
    (if port
      (connect
        {:host "127.0.0.1"
         :port port})
      (display ["; No .nrepl-port file found"]))))

(defn eval-str [opts]
  (with-conn-or-warn
    (fn [_]
      (let [context (a.get opts :context)]
        (eval-str-raw
          {:code (.. "(do "
                     (if context
                       (.. "(in-ns '" context ")")
                       "(in-ns #?(:clj 'user, :cljs 'cljs.user))")
                     " *1)")}
          (fn [])))
      (eval-str-raw opts (or opts.cb #(display-result opts $1))))))

(defn doc-str [opts]
  (eval-str
    (a.merge
      opts
      {:code (.. "(do (require 'clojure.repl)"
                 "    (clojure.repl/doc " opts.code "))")
       :cb (with-all-msgs-fn
             (fn [msgs]
               (-> msgs
                   (->> (a.map #(a.get $1 :out))
                        (a.filter a.string?)
                        (a.rest)
                        (str.join "\n"))
                   (text.prefixed-lines "; ")
                   (display))))})))

(defn- jar->zip [path]
  (if (text.starts-with path "jar:file:")
    (string.gsub path "^jar:file:(.+)!/?(.+)$"
                 (fn [zip file]
                   (.. "zipfile:" zip "::" file)))
    path))

(defn def-str [opts]
  (eval-str
    (a.merge
      opts
      {:code (.. "(mapv #(% (meta #'" opts.code "))
      [(comp #(.toString %)
      (some-fn (comp #?(:clj clojure.java.io/resource :cljs identity)
      :file) :file))
      :line :column])")
       :cb (with-all-msgs-fn
             (fn [msgs]
               (let [val (a.get (a.first msgs) :value)
                     (ok? res) (when val
                                 (eval.str val))]
                 (if ok?
                   (let [[path line column] res]
                     (editor.go-to (jar->zip path) line column))
                   (display ["; Couldn't find definition."])))))})))

(defn eval-file [opts]
  (eval-str-raw
    (a.assoc opts :code (.. "(load-file \"" opts.file-path "\")"))
    #(display-result opts $1)))

(defn interrupt []
  (with-conn-or-warn
    (fn [conn]
      (let [msgs (->> (a.vals conn.msgs)
                      (a.filter
                        (fn [msg]
                          (= :eval msg.msg.op))))]
        (if (a.empty? msgs)
          (display ["; Nothing to interrupt"] {:break? true})
          (do
            (table.sort
              msgs
              (fn [a b]
                (< a.sent-at b.sent-at)))
            (let [oldest (a.first msgs)]
              (send {:op :interrupt
                     :id oldest.msg.id
                     :session oldest.msg.session})
              (display
                [(.. "; Interrupted: "
                     (text.left-sample
                       oldest.msg.code
                       (editor.percent-width
                         config.interrupt.sample-limit)))]
                {:break? true}))))))))

(defn- eval-str-fn [code]
  (fn []
    (nvim.ex.ConjureEval code)))

(def last-exception (eval-str-fn "*e"))
(def result-1 (eval-str-fn "*1"))
(def result-2 (eval-str-fn "*2"))
(def result-3 (eval-str-fn "*3"))

(defn view-source []
  (let [word (a.get (extract.word) :content)]
    (when (not (a.empty? word))
      (display [(.. "; source (word): " word)] {:break? true})
      (eval-str
        {:code (.. "(do (require 'clojure.repl)"
                   "(clojure.repl/source " word "))")
         :context (extract.context)
         :cb (with-all-msgs-fn
               (fn [msgs]
                 (let [source (->> msgs
                                   (a.map #(a.get $1 :out))
                                   (a.filter a.string?)
                                   (str.join "\n"))]
                   (display
                     (text.split-lines
                       (if (= "Source not found\n" source)
                         (.. "; " source)
                         source))))))}))))

(defn clone-current-session []
  (with-conn-or-warn
    (fn [conn]
      (clone-session (a.get conn :session)))))

(defn clone-fresh-session []
  (with-conn-or-warn
    (fn [conn]
      (clone-session))))

(defn- close-session [session cb]
  (send {:op :close :session session} cb))

(defn close-current-session []
  (with-conn-or-warn
    (fn [conn]
      (let [session (a.get conn :session)]
        (a.assoc conn :session nil)
        (display [(.. "; Closed current session: " session)]
                 {:break? true})
        (close-session session assume-or-create-session)))))

(defn- display-given-sessions [sessions cb]
  (let [current (a.get-in state [:conn :session])]
    (display (a.concat [(.. "; Sessions (" (a.count sessions) "):")]
                       (a.map-indexed (fn [[idx session]]
                                        (.. ";  " idx " - " session
                                            (if (= current session)
                                              " (current)"
                                              "")))
                                      sessions))
             {:break? true})
    (when cb
      (cb sessions))))

(defn display-sessions [cb]
  (with-sessions
    (fn [sessions]
      (display-given-sessions sessions cb))))

(defn close-all-sessions []
  (with-sessions
    (fn [sessions]
      (a.run! close-session sessions)
      (display [(.. "; Closed all sessions (" (a.count sessions)")")]
               {:break? true})
      (clone-session))))

(defn- cycle-session [f]
  (with-conn-or-warn
    (fn [conn]
      (with-sessions
        (fn [sessions]
          (if (= 1 (a.count sessions))
            (display ["; No other sessions"] {:break? true})
            (let [session (a.get conn :session)]
              (assume-session (->> sessions
                                   (ll.create)
                                   (ll.cycle)
                                   (ll.until #(f session $1))
                                   (ll.val))))))))))

(defn next-session []
  (cycle-session
    (fn [current node]
      (= current (->> node (ll.prev) (ll.val))))))

(defn prev-session []
  (cycle-session
    (fn [current node]
      (= current (->> node (ll.next) (ll.val))))))

(defn select-session-interactive []
  (with-sessions
    (fn [sessions]
      (if (= 1 (a.count sessions))
        (display ["; No other sessions"] {:break? true})
        (display-given-sessions
          sessions
          (fn []
            (nvim.ex.redraw_)
            (let [n (nvim.fn.str2nr (extract.input "Session number: "))]
              (if (<= 1 n (a.count sessions))
                (assume-session (a.get sessions n))
                (display ["; Invalid session number."])))))))))

(defn on-filetype []
  (mapping.buf :n config.mappings.disconnect
               :conjure.lang.clojure-nrepl :disconnect)
  (mapping.buf :n config.mappings.connect-port-file
               :conjure.lang.clojure-nrepl :connect-port-file)
  (mapping.buf :n config.mappings.interrupt
               :conjure.lang.clojure-nrepl :interrupt)

  (mapping.buf :n config.mappings.last-exception
               :conjure.lang.clojure-nrepl :last-exception)
  (mapping.buf :n config.mappings.result-1 :conjure.lang.clojure-nrepl :result-1)
  (mapping.buf :n config.mappings.result-2 :conjure.lang.clojure-nrepl :result-2)
  (mapping.buf :n config.mappings.result-3 :conjure.lang.clojure-nrepl :result-3)
  (mapping.buf :n config.mappings.view-source :conjure.lang.clojure-nrepl :view-source)

  (mapping.buf :n config.mappings.session-clone
               :conjure.lang.clojure-nrepl :clone-current-session)
  (mapping.buf :n config.mappings.session-fresh
               :conjure.lang.clojure-nrepl :clone-fresh-session)
  (mapping.buf :n config.mappings.session-close
               :conjure.lang.clojure-nrepl :close-current-session)
  (mapping.buf :n config.mappings.session-close-all
               :conjure.lang.clojure-nrepl :close-all-sessions)
  (mapping.buf :n config.mappings.session-list
               :conjure.lang.clojure-nrepl :display-sessions)
  (mapping.buf :n config.mappings.session-next
               :conjure.lang.clojure-nrepl :next-session)
  (mapping.buf :n config.mappings.session-prev
               :conjure.lang.clojure-nrepl :prev-session)
  (mapping.buf :n config.mappings.session-select
               :conjure.lang.clojure-nrepl :select-session-interactive)
  (mapping.buf :n config.mappings.session-type
               :conjure.lang.clojure-nrepl :display-session-type))

(when (not state.loaded?)
  (a.assoc state :loaded? true)
  (vim.schedule
    (fn []
      (nvim.ex.augroup :conjure_clojure_nrepl_cleanup)
      (nvim.ex.autocmd_)
      (nvim.ex.autocmd
        "VimLeavePre *"
        (bridge.viml->lua :conjure.lang.clojure-nrepl :disconnect {}))
      (nvim.ex.augroup :END)

      (connect-port-file))))
