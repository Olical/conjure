(module conjure.client.clojure.nrepl.action
  {require {text conjure.text
            extract conjure.extract
            editor conjure.editor
            ll conjure.linked-list
            log conjure.log
            fs conjure.fs
            eval conjure.aniseed.eval
            str conjure.aniseed.string
            nvim conjure.aniseed.nvim
            view conjure.aniseed.view
            config conjure.config
            server conjure.client.clojure.nrepl.server
            ui conjure.client.clojure.nrepl.ui
            a conjure.aniseed.core
            nrepl conjure.remote.nrepl}})

(defn- require-ns [ns]
  (when ns
    (server.eval
      {:code (.. "(require '" ns ")")}
      (fn []))))

(def- cfg (config.get-in-fn [:client :clojure :nrepl]))

(defn passive-ns-require []
  (when (and (cfg [:eval :auto_require])
             (server.connected?))
    (require-ns (extract.context))))

(defn connect-port-file [opts]
  (let [port (-?>> (cfg [:connection :port_files])
                   (a.map fs.resolve-above)
                   (a.some a.slurp)
                   (tonumber))]
    (if port
      (server.connect
        {:host (cfg [:connection :default_host])
         :port port
         :cb (fn []
               (let [cb (a.get opts :cb)]
                 (when cb
                   (cb)))
               (passive-ns-require))})
      (when (not (a.get opts :silent?))
        (log.append ["; No nREPL port file found"] {:break? true})))))

(defn- try-ensure-conn [cb]
  (if (not (server.connected?))
    (connect-port-file
      {:silent? true
       :cb cb})
    (when cb
      (cb))))

(defn connect-host-port [opts]
  (if (and (not opts.host) (not opts.port))
    (connect-port-file)
    (let [parsed-port (when (= :string (type opts.port))
                        (tonumber opts.port))]

      (if parsed-port
        (server.connect
          {:host (or opts.host (cfg [:connection :default_host]))
           :port parsed-port
           :cb passive-ns-require})
        (log.append [(.. "; Could not parse '" opts.port "' as a port number")])))))

(defn- eval-cb-fn [opts]
  (fn [resp]
    (when (and (a.get opts :on-result)
               (a.get resp :value))
      (opts.on-result resp.value))

    (let [cb (a.get opts :cb)]
      (if cb
        (cb resp)
        (when (not opts.passive?)
          (ui.display-result resp opts))))))

(defn eval-str [opts]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (when (and opts.context (not (a.get-in conn [:seen-ns opts.context])))
            (server.eval
              {:code (.. "(ns " opts.context ")")}
              (fn []))
            (a.assoc-in conn [:seen-ns opts.context] true))

          (server.eval opts (eval-cb-fn opts)))))))

(defn- with-info [opts f]
  (server.with-conn-and-op-or-warn
    :info
    (fn [conn]
      (server.send
        {:op :info
         :ns (or opts.context "user")
         :symbol opts.code
         :session conn.session}
        (fn [msg]
          (f (when (not msg.status.no-info)
               msg)))))))

(defn- java-info->lines [{: arglists-str : class : member : javadoc}]
  (a.concat
    [(str.join
       (a.concat ["; " class]
                 (when member
                   ["/" member])))]
    (when (not (a.empty? arglists-str))
      [(.. "; (" (str.join " " (text.split-lines arglists-str)) ")")])
    (when javadoc
      [(.. "; " javadoc)])))

(defn doc-str [opts]
  (try-ensure-conn
    (fn []
      (require-ns "clojure.repl")
      (server.eval
        (a.merge
          {} opts
          {:code (.. "(clojure.repl/doc " opts.code ")")})
        (nrepl.with-all-msgs-fn
          (fn [msgs]
            (if (a.some (fn [msg]
                          (or (a.get msg :out)
                              (a.get msg :err)))
                        msgs)
              (a.run!
                #(ui.display-result
                   $1
                   {:simple-out? true :ignore-nil? true})
                msgs)
              (do
                (log.append ["; No results, checking CIDER's info op"])
                (with-info
                  opts
                  (fn [info]
                    (if
                      (a.nil? info)
                      (log.append ["; Nothing found via CIDER's info either"])

                      info.javadoc
                      (log.append (java-info->lines info))

                      info.doc
                      (log.append
                        (a.concat
                          [(.. "; " info.ns "/" info.name)
                           (.. "; (" info.arglists-str ")")]
                          (text.prefixed-lines info.doc "; ")))

                      (log.append
                        (a.concat
                          ["; Unknown result, it may still be helpful"]
                          (text.prefixed-lines (view.serialise info) "; "))))))))))))))

(defn- nrepl->nvim-path [path]
  (if
    (text.starts-with path "jar:file:")
    (string.gsub path "^jar:file:(.+)!/?(.+)$"
                 (fn [zip file]
                   (.. "zipfile:" zip "::" file)))

    (text.starts-with path "file:")
    (string.gsub path "^file:(.+)$"
                 (fn [file]
                   file))

    path))

(defn def-str [opts]
  (try-ensure-conn
    (fn []
      (with-info
        opts
        (fn [info]
          (if
            (a.nil? info)
            (log.append ["; No definition information found"])

            info.candidates
            (log.append
              (a.concat
                ["; Multiple candidates found"]
                (a.map #(.. $1 "/" opts.code) (a.keys info.candidates))))

            info.javadoc
            (log.append ["; Can't open source, it's Java"
                         (.. "; " info.javadoc)])

            info.special-form
            (log.append ["; Can't open source, it's a special form"
                         (when info.url (.. "; " info.url))])

            (and info.file info.line)
            (let [column (or info.column 1)
                  path (nrepl->nvim-path info.file)]
              (editor.go-to path info.line column)
              (log.append [(.. "; " path " [" info.line " " column "]")]
                          {:suppress-hud? true}))

            (log.append ["; Unsupported target"
                         (.. "; " (a.pr-str info))])))))))

(defn eval-file [opts]
  (try-ensure-conn
    (fn []
      (server.eval
        (a.assoc opts :code (.. "(#?(:cljs cljs.core/load-file"
                                " :default clojure.core/load-file)"
                                " \"" opts.file-path "\")"))
        (eval-cb-fn opts)))))

(defn interrupt []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (let [msgs (->> (a.vals conn.msgs)
                          (a.filter
                            (fn [msg]
                              (= :eval msg.msg.op))))

                order-66
                (fn [{: id : session : code}]
                  (server.send
                    {:op :interrupt
                     :interrupt-id id
                     :session session})
                  (server.enrich-session-id
                    session
                    (fn [sess]
                      (log.append
                        [(.. "; Interrupted: "
                             (if code
                               (text.left-sample
                                 code
                                 (editor.percent-width
                                   (cfg [:interrupt :sample_limit])))
                               (.. "session: " (sess.str) "")))]
                        {:break? true}))))]

            (if (a.empty? msgs)
              (order-66 {:session conn.session})
              (do
                (table.sort
                  msgs
                  (fn [a b]
                    (< a.sent-at b.sent-at)))
                (order-66 (a.get (a.first msgs) :msg)))))))))
  )

(defn- eval-str-fn [code]
  (fn []
    (nvim.ex.ConjureEval code)))

(def last-exception (eval-str-fn "*e"))
(def result-1 (eval-str-fn "*1"))
(def result-2 (eval-str-fn "*2"))
(def result-3 (eval-str-fn "*3"))

(defn view-source []
  (try-ensure-conn
    (fn []
      (let [word (a.get (extract.word) :content)]
        (when (not (a.empty? word))
          (log.append [(.. "; source (word): " word)] {:break? true})
          (require-ns "clojure.repl")
          (eval-str
            {:code (.. "(clojure.repl/source " word ")")
             :context (extract.context)
             :cb #(ui.display-result
                    $1
                    {:raw-out? true
                     :ignore-nil? true})}))))))

(defn clone-current-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.enrich-session-id
            (a.get conn :session)
            server.clone-session))))))

(defn clone-fresh-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.clone-session))))))

(defn close-current-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.enrich-session-id
            (a.get conn :session)
            (fn [sess]
              (a.assoc conn :session nil)
              (log.append [(.. "; Closed current session: " (sess.str))]
                          {:break? true})
              (server.close-session sess #(server.assume-or-create-session)))))))))

(defn display-sessions [cb]
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (ui.display-sessions sessions cb))))))

(defn close-all-sessions []
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (a.run! server.close-session sessions)
          (log.append [(.. "; Closed all sessions (" (a.count sessions)")")]
                      {:break? true})
          (server.clone-session))))))

(defn- cycle-session [f]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.with-sessions
            (fn [sessions]
              (if (= 1 (a.count sessions))
                (log.append ["; No other sessions"] {:break? true})
                (let [session (a.get conn :session)]
                  (->> sessions
                       (ll.create)
                       (ll.cycle)
                       (ll.until #(f session $1))
                       (ll.val)
                       (server.assume-session)))))))))))

(defn next-session []
  (cycle-session
    (fn [current node]
      (= current (a.get (->> node (ll.prev) (ll.val)) :id)))))

(defn prev-session []
  (cycle-session
    (fn [current node]
      (= current (a.get (->> node (ll.next) (ll.val)) :id)))))

(defn select-session-interactive []
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (if (= 1 (a.count sessions))
            (log.append ["; No other sessions"] {:break? true})
            (ui.display-sessions
              sessions
              (fn []
                (nvim.ex.redraw_)
                (let [n (nvim.fn.str2nr (extract.prompt "Session number: "))]
                  (if (<= 1 n (a.count sessions))
                    (server.assume-session (a.get sessions n))
                    (log.append ["; Invalid session number."])))))))))))

(defn run-all-tests []
  (try-ensure-conn
    (fn []
      (log.append ["; run-all-tests"] {:break? true})
      (require-ns "clojure.test")
      (server.eval
        {:code "(clojure.test/run-all-tests)"}
        #(ui.display-result
           $1
           {:simple-out? true
            :ignore-nil? true})))))

(defn- run-ns-tests [ns]
  (try-ensure-conn
    (fn []
      (when ns
        (log.append [(.. "; run-ns-tests: " ns)]
                    {:break? true})
        (require-ns "clojure.test")
        (server.eval
          {:code (.. "(clojure.test/run-tests '" ns ")")}
          #(ui.display-result
             $1
             {:simple-out? true
              :ignore-nil? true}))))))

(defn run-current-ns-tests []
  (run-ns-tests (extract.context)))

(defn run-alternate-ns-tests []
  (let [current-ns (extract.context)]
    (run-ns-tests
      (if (text.ends-with current-ns "-test")
        (string.sub current-ns 1 -6)
        (.. current-ns "-test")))))

(defn run-current-test []
  (try-ensure-conn
    (fn []
      (let [form (extract.form {:root? true})]
        (when form
          (let [(test-name sub-count)
                (string.gsub form.content ".*deftest%s+(.-)%s+.*" "%1")]
            (when (and (not (a.empty? test-name)) (= 1 sub-count))
              (log.append [(.. "; run-current-test: " test-name)]
                          {:break? true})
              (require-ns "clojure.test")
              (server.eval
                {:code (.. "(clojure.test/test-vars"
                           "  [(doto (resolve '" test-name ")"
                           "     (assert \"" test-name " is not a var\"))])")
                 :context (extract.context)}
                (nrepl.with-all-msgs-fn
                  (fn [msgs]
                    (if (and (= 2 (a.count msgs))
                             (= "nil" (a.get (a.first msgs) :value)))
                      (log.append ["; Success!"])
                      (a.run! #(ui.display-result
                                 $1
                                 {:simple-out? true
                                  :ignore-nil? true})
                              msgs))))))))))))

(defn- refresh-impl [op]
  (server.with-conn-and-op-or-warn
    op
    (fn [conn]
      (server.send
        (a.merge
          {:op op
           :session conn.session
           :after (cfg [:refresh :after])
           :before (cfg [:refresh :before])
           :dirs (cfg [:refresh :dirs])})
        (fn [msg]
          (if
            msg.reloading
            (log.append msg.reloading)

            msg.error
            (log.append [(.. "; Error while reloading "
                             msg.error-ns)])

            msg.status.ok
            (log.append ["; Refresh complete"])

            msg.status.done
            nil

            (ui.display-result msg)))))))

(defn refresh-changed []
  (try-ensure-conn
    (fn []
      (log.append ["; Refreshing changed namespaces"] {:break? true})
      (refresh-impl :refresh))))

(defn refresh-all []
  (try-ensure-conn
    (fn []
      (log.append ["; Refreshing all namespaces"] {:break? true})
      (refresh-impl :refresh-all))))

(defn refresh-clear []
  (try-ensure-conn
    (fn []
      (log.append ["; Clearing refresh cache"] {:break? true})
      (server.with-conn-and-op-or-warn
        :refresh-clear
        (fn [conn]
          (server.send
            {:op :refresh-clear
             :session conn.session}
            (nrepl.with-all-msgs-fn
              (fn [msgs]
                (log.append ["; Clearing complete"])))))))))

(defn shadow-select [build]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (log.append [(.. "; shadow-cljs (select): " build)] {:break? true})
          (server.eval
            {:code (.. "(shadow.cljs.devtools.api/nrepl-select :" build ")")}
            ui.display-result)
          (passive-ns-require))))))

(defn piggieback [code]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (log.append [(.. "; piggieback: " code)] {:break? true})
          (require-ns "cider.piggieback")
          (server.eval
            {:code (.. "(cider.piggieback/cljs-repl " code ")")}
            ui.display-result)
          (passive-ns-require))))))

(defn- clojure->vim-completion [{:candidate word
                                 :type kind
                                 : ns
                                 :doc info
                                 : arglists}]
  {:word word
   :menu (table.concat
           [ns
            (when arglists
              (table.concat arglists " "))]
           " ")
   :info info
   :kind (when (not (a.empty? kind))
           (string.upper
             (string.sub kind 1 1)))})


(defn- extract-completion-context [prefix]
  (let [root-form (extract.form {:root? true})]
    (when root-form
      (let [{: content : range} root-form
            lines (text.split-lines content)
            [row col] (nvim.win_get_cursor 0)
            lrow (- row (a.get-in range [:start 1]))
            line-index (a.inc lrow)
            lcol (if (= lrow 0)
                   (- col (a.get-in range [:start 2]))
                   col)
            original (a.get lines line-index)
            spliced (.. (string.sub
                          original
                          1 lcol)
                        "__prefix__"
                        (string.sub
                          original
                          (a.inc lcol)))]
        (-> lines
            (a.assoc line-index spliced)
            (->> (str.join "\n")))))))

(defn- enhanced-cljs-completion? []
  (cfg [:completion :cljs :use_suitable]))

(defn completions [opts]
  (server.with-conn-and-op-or-warn
    :complete
    (fn [conn]
      (server.send
        {:op :complete
         :session conn.session
         :ns opts.context
         :symbol opts.prefix
         :context (when (cfg [:completion :with_context])
                    (extract-completion-context opts.prefix))
         :extra-metadata [:arglists :doc]
         :enhanced-cljs-completion? (when (enhanced-cljs-completion?) "t")}
        (nrepl.with-all-msgs-fn
          (fn [msgs]
            (->> (a.get (a.last msgs) :completions)
                 (a.map clojure->vim-completion)
                 (opts.cb))))))
    {:silent? true
     :else opts.cb}))

(defn out-subscribe []
  (try-ensure-conn)
  (log.append ["; Subscribing to out"] {:break? true})
  (server.with-conn-and-op-or-warn
    :out-subscribe
    (fn [conn]
      (server.send {:op :out-subscribe}))))

(defn out-unsubscribe []
  (try-ensure-conn)
  (log.append ["; Unsubscribing from out"] {:break? true})
  (server.with-conn-and-op-or-warn
    :out-unsubscribe
    (fn [conn]
      (server.send {:op :out-unsubscribe}))))
