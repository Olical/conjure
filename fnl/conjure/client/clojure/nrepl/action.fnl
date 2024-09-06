(local autoload (require :nfnl.autoload))
(local a (autoload :conjure.aniseed.core))
(local auto-repl (autoload :conjure.client.clojure.nrepl.auto-repl))
(local config (autoload :conjure.config))
(local editor (autoload :conjure.editor))
(local extract (autoload :conjure.extract))
(local fs (autoload :conjure.fs))
(local hook (autoload :conjure.hook))
(local ll (autoload :conjure.linked-list))
(local log (autoload :conjure.log))
(local nrepl (autoload :conjure.remote.nrepl))
(local nvim (autoload :conjure.aniseed.nvim))
(local parse (autoload :conjure.client.clojure.nrepl.parse))
(local server (autoload :conjure.client.clojure.nrepl.server))
(local str (autoload :conjure.aniseed.string))
(local text (autoload :conjure.text))
(local ui (autoload :conjure.client.clojure.nrepl.ui))
(local view (autoload :conjure.aniseed.view))

(fn require-ns [ns]
  (when ns
    (server.eval
      {:code (.. "(require '" ns ")")}
      (fn []))))

(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(fn passive-ns-require []
  (when (and (cfg [:eval :auto_require])
             (server.connected?))
    (require-ns (extract.context))))

(fn connect-port-file [opts]
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

(fn try-ensure-conn [cb]
  (if (not (server.connected?))
    (hook.exec :client-clojure-nrepl-passive-connect cb)
    (when cb
      (cb))))

(fn connect-host-port [opts]
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

(fn eval-cb-fn [opts]
  (fn [resp]
    (when (and (a.get opts :on-result)
               (a.get resp :value))
      (opts.on-result resp.value))

    (let [cb (a.get opts :cb)]
      (if cb
        (cb resp)
        (when (not opts.passive?)
          (ui.display-result resp opts))))))

(fn eval-str [opts]
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

(fn with-info [opts f]
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

(fn java-info->lines [{: arglists-str : class : member : javadoc}]
  (a.concat
    [(str.join
       (a.concat ["; " class]
                 (when member
                   ["/" member])))]
    (when (not (a.empty? arglists-str))
      [(.. "; (" (str.join " " (text.split-lines arglists-str)) ")")])
    (when javadoc
      [(.. "; " javadoc)])))

(fn doc-str [opts]
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

(fn nrepl->nvim-path [path]
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

(fn def-str [opts]
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

(fn escape-backslashes [s]
  (s:gsub "\\" "\\\\"))

(fn eval-file [opts]
  (try-ensure-conn
    (fn []
      (server.eval
        (a.assoc opts :code (.. "(#?(:cljs cljs.core/load-file"
                                " :default clojure.core/load-file)"
                                " \"" (escape-backslashes opts.file-path) "\")"))
        (eval-cb-fn opts)))))

(fn interrupt []
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

(fn eval-str-fn [code]
  (fn []
    (nvim.ex.ConjureEval code)))

(local last-exception (eval-str-fn "*e"))
(local result-1 (eval-str-fn "*1"))
(local result-2 (eval-str-fn "*2"))
(local result-3 (eval-str-fn "*3"))
(local view-tap (eval-str-fn "(conjure.internal/dump-tap-queue!)"))

(fn view-source []
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

(fn clone-current-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.enrich-session-id
            (a.get conn :session)
            server.clone-session))))))

(fn clone-fresh-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.clone-session))))))

(fn close-current-session []
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

(fn display-sessions [cb]
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (ui.display-sessions sessions cb))))))

(fn close-all-sessions []
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (a.run! server.close-session sessions)
          (log.append [(.. "; Closed all sessions (" (a.count sessions) ")")]
                      {:break? true})
          (server.clone-session))))))

(fn cycle-session [f]
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

(fn next-session []
  (cycle-session
    (fn [current node]
      (= current (a.get (->> node (ll.prev) (ll.val)) :id)))))

(fn prev-session []
  (cycle-session
    (fn [current node]
      (= current (a.get (->> node (ll.next) (ll.val)) :id)))))

(fn select-session-interactive []
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

(local test-runners
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

(fn test-cfg [k]
  (let [runner (cfg [:test :runner])]
    (or (a.get-in test-runners [runner k])
        (error (str.join ["No test-runners configuration for " runner " / " k])))))

(fn require-test-runner []
  (require-ns (test-cfg :namespace)))

(fn test-runner-code [fn-config-name ...]
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

(fn run-all-tests []
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

(fn run-ns-tests [ns]
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

(fn run-current-ns-tests []
  (run-ns-tests (extract.context)))

(fn run-alternate-ns-tests []
  (let [current-ns (extract.context)]
    (run-ns-tests
      (if (text.ends-with current-ns "-test")
        current-ns
        (.. current-ns "-test")))))

(fn extract-test-name-from-form [form]
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

(fn run-current-test []
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

(fn refresh-impl [op]
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

(fn use-clj-reload-backend? []
  (= (cfg [:refresh :backend]) "clj-reload"))

(fn refresh-changed []
  (let [use-clj-reload? (use-clj-reload-backend?)]
    (try-ensure-conn
      (fn []
        (log.append [(str.join ["; Refreshing changed namespaces using '" (if use-clj-reload? "clj-reload" "tools.namespace") "'"])] {:break? true})
        (refresh-impl (if use-clj-reload? :cider.clj-reload/reload :refresh))))))

(fn refresh-all []
  (let [use-clj-reload? (use-clj-reload-backend?)]
    (try-ensure-conn
      (fn []
        (log.append [(str.join ["; Refreshing all namespaces using '" (if use-clj-reload? "clj-reload" "tools.namespace") "'"])] {:break? true})
        (refresh-impl (if use-clj-reload? :cider.clj-reload/reload-all :refresh-all))))))

(fn refresh-clear []
  (let [use-clj-reload? (use-clj-reload-backend?)]
    (try-ensure-conn
      (fn []
        (log.append [(str.join ["; Clearning reload cache using '" (if use-clj-reload? "clj-reload" "tools.namespace") "'"])] {:break? true})
        (server.with-conn-and-ops-or-warn
          [:refresh-clear]
          (fn [conn]
            (server.send
              {:op (if use-clj-reload? :cider.clj-reload/reload-clear :refresh-clear)
               :session conn.session}
              (nrepl.with-all-msgs-fn
                (fn [msgs]
                  (log.append ["; Clearing complete"]))))))))))

(fn shadow-select [build]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (log.append [(.. "; shadow-cljs (select): " build)] {:break? true})
          (server.eval
            {:code (.. "#?(:clj (shadow.cljs.devtools.api/nrepl-select :" build ") :cljs :already-selected)")}
            ui.display-result)
          (passive-ns-require))))))

(fn piggieback [code]
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

(fn clojure->vim-completion [{:candidate word
                                 :type kind
                                 : ns
                                 :doc info
                                 : arglists}]
  {:word word
   :menu (str.join
           " "
           [ns
            (when arglists
              (str.join " " arglists))])
   :info (when (= :string (type info))
           info)
   :kind (when (not (a.empty? kind))
           (string.upper
             (string.sub kind 1 1)))})

(fn extract-completion-context [prefix]
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

(fn enhanced-cljs-completion? []
  (cfg [:completion :cljs :use_suitable]))

(fn completions [opts]
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

(fn out-subscribe []
  (try-ensure-conn)
  (log.append ["; Subscribing to out"] {:break? true})
  (server.with-conn-and-ops-or-warn
    [:out-subscribe]
    (fn [conn]
      (server.send {:op :out-subscribe}))))

(fn out-unsubscribe []
  (try-ensure-conn)
  (log.append ["; Unsubscribing from out"] {:break? true})
  (server.with-conn-and-ops-or-warn
    [:out-unsubscribe]
    (fn [conn]
      (server.send {:op :out-unsubscribe}))))

{: clone-current-session
 : clone-fresh-session
 : close-all-sessions
 : close-current-session
 : completions
 : connect-host-port
 : connect-port-file
 : def-str
 : display-sessions
 : doc-str
 : escape-backslashes
 : eval-file
 : eval-str
 : extract-test-name-from-form
 : interrupt
 : last-exception
 : next-session
 : out-subscribe
 : out-unsubscribe
 : passive-ns-require
 : piggieback
 : prev-session
 : refresh-all
 : refresh-changed
 : refresh-clear
 : result-1
 : result-2
 : result-3
 : run-all-tests
 : run-alternate-ns-tests
 : run-current-ns-tests
 : run-current-test
 : select-session-interactive
 : shadow-select
 : test-runners
 : view-source
 : view-tap}
