(module conjure.client.clojure.nrepl.action
  {autoload {text conjure.text
             extract conjure.extract
             editor conjure.editor
             ll conjure.linked-list
             log conjure.log
             fs conjure.fs
             hook conjure.hook
             client conjure.client
             eval conjure.aniseed.eval
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             view conjure.aniseed.view
             a conjure.aniseed.core
             config conjure.config
             server conjure.client.clojure.nrepl.server
             ui conjure.client.clojure.nrepl.ui
             state conjure.client.clojure.nrepl.state
             parse conjure.client.clojure.nrepl.parse
             auto-repl conjure.client.clojure.nrepl.auto-repl
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
  (let [resolved-path (-?>> (cfg [:connection :port_files]) (fs.resolve-above))
        resolved (when resolved-path
                   (let [port (a.slurp resolved-path)]
                     (when port
                       {:path resolved-path
                        :port (tonumber port)})))]
    (if resolved
      (server.connect
        {:host (cfg [:connection :default_host])
         :port_file_path (?. resolved :path)
         :port (?. resolved :port)
         :cb (fn []
               (let [cb (a.get opts :cb)]
                 (when cb
                   (cb)))
               (passive-ns-require))
         :connect-opts (a.get opts :connect-opts)})
      (when (not (a.get opts :silent?))
        (log.append ["; No nREPL port file found"] {:break? true})
        (auto-repl.upsert-auto-repl-proc)))))

(hook.define
  :client-clojure-nrepl-passive-connect
  (fn [cb]
    (connect-port-file
      {:silent? true
       :cb cb})))

(defn- try-ensure-conn [cb]
  (if (not (server.connected?))
    (hook.exec :client-clojure-nrepl-passive-connect cb)
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
        (log.append [(str.join ["; Could not parse '" (or opts.port "nil") "' as a port number"])])))))

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
  (server.with-conn-and-ops-or-warn
    [:info :lookup]
    (fn [conn ops]
      (server.send
        (if
          ops.info
          {:op :info
           :ns (or opts.context "user")
           :symbol opts.code
           :session conn.session}

          ops.lookup
          {:op :lookup
           :ns (or opts.context "user")
           :sym opts.code
           :session conn.session})
        (fn [msg]
          (f (when (not msg.status.no-info)
               (or (. msg :info) msg))))))))

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
                (log.append ["; No results for (doc ...), checking nREPL info ops"])
                (with-info
                  opts
                  (fn [info]
                    (if
                      (a.nil? info)
                      (log.append ["; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"])

                      (= :string (type info.javadoc))
                      (log.append (java-info->lines info))

                      (= :string (type info.doc))
                      (log.append
                        (a.concat
                          [(str.join ["; " info.ns "/" info.name])
                           (str.join ["; " info.arglists-str])]
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
                   (if (> (tonumber (string.sub nvim.g.loaded_zipPlugin 2)) 31)
                     (.. "zipfile://" zip "::" file)
                     (.. "zipfile:" zip "::" file))))

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
                (order-66 (a.get (a.first msgs) :msg))))))))))

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

(def- test-runners
  {:clojure
   {:namespace "clojure.test"
    :all-fn "run-all-tests"
    :ns-fn "run-tests"
    :single-fn "test-vars"
    :default-call-suffix ""
    :name-prefix "[(resolve '"
    :name-suffix ")]"}
   :clojurescript
   {:namespace "cljs.test"
    :all-fn "run-all-tests"
    :ns-fn "run-tests"
    :single-fn "test-vars"
    :default-call-suffix ""
    :name-prefix "[(resolve '"
    :name-suffix ")]"}
   :kaocha
   {:namespace "kaocha.repl"
    :all-fn "run-all"
    :ns-fn "run"
    :single-fn "run"
    :default-call-suffix "{:kaocha/color? false}"
    :name-prefix "#'"
    :name-suffix ""}})

(defn- test-cfg [k]
  (let [runner (cfg [:test :runner])]
    (or (a.get-in test-runners [runner k])
        (error (str.join ["No test-runners configuration for " runner " / " k])))))

(defn- require-test-runner []
  (require-ns (test-cfg :namespace)))

(defn- test-runner-code [fn-config-name ...]
  (..
    "("
    (str.join
      " "
      [(.. (test-cfg :namespace) "/"
           (test-cfg (.. fn-config-name "-fn")))
       ...])
    (or (cfg [:test :call_suffix])
        (test-cfg :default-call-suffix))
    ")"))

(defn run-all-tests []
  (try-ensure-conn
    (fn []
      (log.append ["; run-all-tests"] {:break? true})
      (require-test-runner)
      (server.eval
        {:code (test-runner-code :all)}
        #(ui.display-result
           $1
           {:simple-out? true
            :raw-out? (cfg [:test :raw_out])
            :ignore-nil? true})))))

(defn- run-ns-tests [ns]
  (try-ensure-conn
    (fn []
      (when ns
        (log.append [(.. "; run-ns-tests: " ns)]
                    {:break? true})
        (require-test-runner)
        (server.eval
          {:code (test-runner-code :ns (.. "'" ns))}
          #(ui.display-result
             $1
             {:simple-out? true
              :raw-out? (cfg [:test :raw_out])
              :ignore-nil? true}))))))

(defn run-current-ns-tests []
  (run-ns-tests (extract.context)))

(defn run-alternate-ns-tests []
  (let [current-ns (extract.context)]
    (run-ns-tests
      (if (text.ends-with current-ns "-test")
        current-ns
        (.. current-ns "-test")))))

(defn extract-test-name-from-form [form]
  (var seen-deftest? false)
  (-> (parse.strip-meta form)
      (str.split "%s+")
      (->>
        (a.some
          (fn [part]
            (if
              (a.some (fn [config-current-form-name]
                        (text.ends-with part config-current-form-name))
                      (cfg [:test :current_form_names]))
              (do (set seen-deftest? true) false)

              seen-deftest?
              part))))))

(defn run-current-test []
  (try-ensure-conn
    (fn []
      (let [form (extract.form {:root? true})]
        (when form
          (let [test-name (extract-test-name-from-form form.content)]
            (when test-name
              (log.append [(.. "; run-current-test: " test-name)]
                          {:break? true})
              (require-test-runner)
              (server.eval
                {:code (test-runner-code
                         :single
                         (.. (test-cfg :name-prefix)
                             test-name
                             (test-cfg :name-suffix)))
                 :context (extract.context)}
                (nrepl.with-all-msgs-fn
                  (fn [msgs]
                    (if (and (= 2 (a.count msgs))
                             (= "nil" (a.get (a.first msgs) :value)))
                      (log.append ["; Success!"])
                      (a.run! #(ui.display-result
                                 $1
                                 {:simple-out? true
                                  :raw-out? (cfg [:test :raw_out])
                                  :ignore-nil? true})
                              msgs))))))))))))

(defn- refresh-impl [op]
  (server.with-conn-and-ops-or-warn
    [op]
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
            (log.append [(str.join " " ["; Error while reloading" msg.error-ns])])

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
      (server.with-conn-and-ops-or-warn
        [:refresh-clear]
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
            {:code (.. "#?(:clj (shadow.cljs.devtools.api/nrepl-select :" build ") :cljs :already-selected)")}
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
   :menu (str.join
           " "
           [ns
            (when arglists
              (str.join " " arglists ))])
   :info (when (= :string (type info))
           info)
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
  (server.with-conn-and-ops-or-warn
    [:complete :completions]
    (fn [conn ops]
      (server.send
        (if
          ;; CIDER
          ops.complete
          {:op :complete
           :session conn.session
           :ns opts.context
           :symbol opts.prefix
           :context (when (cfg [:completion :with_context])
                      (extract-completion-context opts.prefix))
           :extra-metadata [:arglists :doc]
           :enhanced-cljs-completion? (when (enhanced-cljs-completion?) "t")}

          ;; nREPL 0.8+
          ops.completions
          {:op :completions
           :session conn.session
           :ns opts.context
           :prefix opts.prefix})

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
  (server.with-conn-and-ops-or-warn
    [:out-subscribe]
    (fn [conn]
      (server.send {:op :out-subscribe}))))

(defn out-unsubscribe []
  (try-ensure-conn)
  (log.append ["; Unsubscribing from out"] {:break? true})
  (server.with-conn-and-ops-or-warn
    [:out-unsubscribe]
    (fn [conn]
      (server.send {:op :out-unsubscribe}))))
