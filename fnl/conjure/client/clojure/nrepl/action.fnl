(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local auto-repl (autoload :conjure.client.clojure.nrepl.auto-repl))
(local config (autoload :conjure.config))
(local editor (autoload :conjure.editor))
(local extract (autoload :conjure.extract))
(local fs (autoload :conjure.fs))
(local hook (autoload :conjure.hook))
(local ll (autoload :conjure.linked-list))
(local log (autoload :conjure.log))
(local nrepl (autoload :conjure.remote.nrepl))
(local parse (autoload :conjure.client.clojure.nrepl.parse))
(local server (autoload :conjure.client.clojure.nrepl.server))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))
(local ui (autoload :conjure.client.clojure.nrepl.ui))

(local M (define :conjure.client.clojure.nrepl.action))

(fn require-ns [ns]
  (when ns
    (server.eval
      {:code (.. "(require '" ns ")")}
      (fn []))))

(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(fn M.passive-ns-require []
  (when (and (cfg [:eval :auto_require])
             (server.connected?))
    (require-ns (extract.context))))

(fn M.connect-port-file [opts]
  (let [resolved-path (-?>> (cfg [:connection :port_files]) (fs.resolve-above))
        resolved (when resolved-path
                   (let [port (core.slurp resolved-path)]
                     (when port
                       {:path resolved-path
                        :port (tonumber port)})))]
    (if resolved
        (server.connect
          {:host (cfg [:connection :default_host])
           :port_file_path (?. resolved :path)
           :port (?. resolved :port)
           :cb (fn []
                 (let [cb (core.get opts :cb)]
                   (when cb
                     (cb)))
                 (M.passive-ns-require))
           :connect-opts (core.get opts :connect-opts)})
        (when (not (core.get opts :silent?))
          (log.append ["; No nREPL port file found"] {:break? true})
          (auto-repl.upsert-auto-repl-proc)))))

(hook.define
  :client-clojure-nrepl-passive-connect
  (fn [cb]
    (M.connect-port-file
      {:silent? true
       :cb cb})))

(fn try-ensure-conn [cb]
  (if (not (server.connected?))
      (hook.exec :client-clojure-nrepl-passive-connect cb)
      (when cb
        (cb))))

(fn M.connect-host-port [opts]
  (if (and (not opts.host) (not opts.port))
      (M.connect-port-file)
      (let [parsed-port (when (= :string (type opts.port))
                          (tonumber opts.port))]

        (if parsed-port
            (server.connect
              {:host (or opts.host (cfg [:connection :default_host]))
               :port parsed-port
               :cb M.passive-ns-require})
            (log.append [(str.join ["; Could not parse '" (or opts.port "nil") "' as a port number"])])))))

(fn eval-cb-fn [opts]
  (fn [resp]
    (when (and (core.get opts :on-result)
               (core.get resp :value))
      (opts.on-result resp.value))

    (let [cb (core.get opts :cb)]
      (if cb
          (cb resp)
          (when (not opts.passive?)
            (ui.display-result resp opts))))))

(fn M.eval-str [opts]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (when (and opts.context (not (core.get-in conn [:seen-ns opts.context])))
            (server.eval
              {:code (.. "(ns " opts.context ")")}
              (fn []))
            (core.assoc-in conn [:seen-ns opts.context] true))

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
  (core.concat
    [(str.join
       (core.concat ["; " class]
                    (when member
                      ["/" member])))]
    (when (not (core.empty? arglists-str))
      [(.. "; (" (str.join " " (text.split-lines arglists-str)) ")")])
    (when javadoc
      [(.. "; " javadoc)])))

(fn M.doc-str [opts]
  (try-ensure-conn
    (fn []
      (require-ns "clojure.repl")
      (server.eval
        (core.merge
          {} opts
          {:code (.. "(clojure.repl/doc " opts.code ")")})
        (nrepl.with-all-msgs-fn
          (fn [msgs]
            (if (core.some (fn [msg]
                             (or (core.get msg :out)
                                 (core.get msg :err)))
                           msgs)
                (core.run!
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
                        (core.nil? info)
                        (log.append ["; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"])

                        (= :string (type info.javadoc))
                        (log.append (java-info->lines info))

                        (= :string (type info.doc))
                        (log.append
                          (core.concat
                            [(str.join ["; " info.ns "/" info.name])
                             (str.join ["; " info.arglists-str])]
                            (text.prefixed-lines info.doc "; ")))

                        (log.append
                          (core.concat
                            ["; Unknown result, it may still be helpful"]
                            (text.prefixed-lines (core.pr-str info) "; "))))))))))))))

(fn nrepl->nvim-path [path]
  (if
    (text.starts-with path "jar:file:")
    (string.gsub path "^jar:file:(.+)!/?(.+)$"
                 (fn [zip file]
                   (if (> (tonumber (string.sub vim.g.loaded_zipPlugin 2)) 31)
                       (.. "zipfile://" zip "::" file)
                       (.. "zipfile:" zip "::" file))))

    (text.starts-with path "file:")
    (string.gsub path "^file:(.+)$"
                 (fn [file]
                   file))

    path))

(fn M.def-str [opts]
  (try-ensure-conn
    (fn []
      (with-info
        opts
        (fn [info]
          (if
            (core.nil? info)
            (log.append ["; No definition information found"])

            info.candidates
            (log.append
              (core.concat
                ["; Multiple candidates found"]
                (core.map #(.. $1 "/" opts.code) (core.keys info.candidates))))

            (and info.file info.line)
            (let [column (or info.column 1)
                  path (nrepl->nvim-path info.file)]
              (editor.go-to path info.line column)
              (log.append [(.. "; " path " [" info.line " " column "]")]
                          {:suppress-hud? true}))

            info.javadoc
            (log.append ["; Can't open source, it's Java"
                         (.. "; " info.javadoc)])

            info.special-form
            (log.append ["; Can't open source, it's a special form"
                         (when info.url (.. "; " info.url))])


            (log.append ["; Unsupported target"
                         (.. "; " (core.pr-str info))])))))))

(fn M.escape-backslashes [s]
  (s:gsub "\\" "\\\\"))

(fn M.eval-file [opts]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.load-file
            (core.assoc opts :code (core.slurp opts.file-path))
            (eval-cb-fn opts)))))))

(fn M.interrupt []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (let [msgs (->> (core.vals conn.msgs)
                          (core.filter
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

            (if (core.empty? msgs)
                (order-66 {:session conn.session})
                (do
                  (table.sort
                    msgs
                    (fn [a b]
                      (< a.sent-at b.sent-at)))
                  (order-66 (core.get (core.first msgs) :msg))))))))))

(fn eval-str-fn [code]
  (fn []
    (vim.api.nvim_exec2 (.. "ConjureEval " code) {})))

(set M.last-exception (eval-str-fn "*e"))
(set M.result-1 (eval-str-fn "*1"))
(set M.result-2 (eval-str-fn "*2"))
(set M.result-3 (eval-str-fn "*3"))
(set M.view-tap (eval-str-fn "(conjure.internal/dump-tap-queue!)"))

(fn M.view-source []
  (try-ensure-conn
    (fn []
      (let [word (core.get (extract.word) :content)]
        (when (not (core.empty? word))
          (log.append [(.. "; source (word): " word)] {:break? true})
          (require-ns "clojure.repl")
          (M.eval-str
            {:code (.. "(clojure.repl/source " word ")")
             :context (extract.context)
             :cb #(ui.display-result
                    $1
                    {:raw-out? true
                     :ignore-nil? true})}))))))

(fn eval-macro-expand [expander]
  (try-ensure-conn
    (fn []
      (let [form (core.get (extract.form {}) :content)]
        (when (not (core.empty? form))
          (log.append [(.. "; " expander " (form): " form)] {:break? true})
          (M.eval-str
            {:code (..
                     (if (= :clojure.walk/macroexpand-all expander)
                         "(require 'clojure.walk) "
                         "")
                     "(" expander " '" form ")")
             :context (extract.context)
             :cb #(ui.display-result
                    $1
                    {:raw-out? true
                     :ignore-nil? true})}))))))

(fn M.macro-expand-1 []
  (eval-macro-expand :macroexpand-1))

(fn M.macro-expand []
  (eval-macro-expand :macroexpand))

(fn M.macro-expand-all []
  (eval-macro-expand :clojure.walk/macroexpand-all))

(fn M.clone-current-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.enrich-session-id
            (core.get conn :session)
            server.clone-session))))))

(fn M.clone-fresh-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.clone-session))))))

(fn M.close-current-session []
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.enrich-session-id
            (core.get conn :session)
            (fn [sess]
              (core.assoc conn :session nil)
              (log.append [(.. "; Closed current session: " (sess.str))]
                          {:break? true})
              (server.close-session sess #(server.assume-or-create-session)))))))))

(fn M.display-sessions [cb]
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (ui.display-sessions sessions cb))))))

(fn M.close-all-sessions []
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (core.run! server.close-session sessions)
          (log.append [(.. "; Closed all sessions (" (core.count sessions) ")")]
                      {:break? true})
          (server.clone-session))))))

(fn cycle-session [f]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (server.with-sessions
            (fn [sessions]
              (if (= 1 (core.count sessions))
                  (log.append ["; No other sessions"] {:break? true})
                  (let [session (core.get conn :session)]
                    (->> sessions
                         (ll.create)
                         (ll.cycle)
                         (ll.until #(f session $1))
                         (ll.val)
                         (server.assume-session)))))))))))

(fn M.next-session []
  (cycle-session
    (fn [current node]
      (= current (core.get (->> node (ll.prev) (ll.val)) :id)))))

(fn M.prev-session []
  (cycle-session
    (fn [current node]
      (= current (core.get (->> node (ll.next) (ll.val)) :id)))))

(fn M.select-session-interactive []
  (try-ensure-conn
    (fn []
      (server.with-sessions
        (fn [sessions]
          (if (= 1 (core.count sessions))
              (log.append ["; No other sessions"] {:break? true})
              (vim.ui.select
                sessions
                {:prompt "Select an nREPL session:"
                 :format_item #(.. $.name " (" $.pretty-type ", " $.id ")")}
                (fn [session]
                  (server.assume-session session)))))))))

(set M.test-runners
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
    (or (core.get-in M.test-runners [runner k])
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

(fn M.run-all-tests []
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

(fn M.run-current-ns-tests []
  (run-ns-tests (extract.context)))

(fn M.run-alternate-ns-tests []
  (let [current-ns (extract.context)]
    (run-ns-tests
      (if (text.ends-with current-ns "-test")
          current-ns
          (.. current-ns "-test")))))

(fn M.extract-test-name-from-form [form]
  (var seen-deftest? false)
  (-> (parse.strip-meta form)
      (str.split "%s+")
      (->>
        (core.some
          (fn [part]
            (if
              (core.some (fn [config-current-form-name]
                           (text.ends-with part config-current-form-name))
                         (cfg [:test :current_form_names]))
              (do (set seen-deftest? true) false)

              seen-deftest?
              part))))))

(fn M.run-current-test []
  (try-ensure-conn
    (fn []
      (let [form (extract.form {:root? true})]
        (when form
          (let [test-name (M.extract-test-name-from-form form.content)]
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
                    (if (and (= 2 (core.count msgs))
                             (= "nil" (core.get (core.first msgs) :value)))
                        (log.append ["; Success!"])
                        (core.run! #(ui.display-result
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
        (core.merge
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

(fn M.refresh-changed []
  (let [use-clj-reload? (use-clj-reload-backend?)]
    (try-ensure-conn
      (fn []
        (log.append [(str.join ["; Refreshing changed namespaces using '" (if use-clj-reload? "clj-reload" "tools.namespace") "'"])] {:break? true})
        (refresh-impl (if use-clj-reload? :cider.clj-reload/reload :refresh))))))

(fn M.refresh-all []
  (let [use-clj-reload? (use-clj-reload-backend?)]
    (try-ensure-conn
      (fn []
        (log.append [(str.join ["; Refreshing all namespaces using '" (if use-clj-reload? "clj-reload" "tools.namespace") "'"])] {:break? true})
        (refresh-impl (if use-clj-reload? :cider.clj-reload/reload-all :refresh-all))))))

(fn M.refresh-clear []
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

(fn M.shadow-select [build]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (log.append [(.. "; shadow-cljs (select): " build)] {:break? true})
          (server.eval
            {:code (.. "#?(:clj (shadow.cljs.devtools.api/nrepl-select :" build ") :cljs :already-selected)")}
            ui.display-result)
          (M.passive-ns-require))))))

(fn M.piggieback [code]
  (try-ensure-conn
    (fn []
      (server.with-conn-or-warn
        (fn [conn]
          (log.append [(.. "; piggieback: " code)] {:break? true})
          (require-ns "cider.piggieback")
          (server.eval
            {:code (.. "(cider.piggieback/cljs-repl " code ")")}
            ui.display-result)
          (M.passive-ns-require))))))

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
   :kind (when (not (core.empty? kind))
           (string.upper
             (string.sub kind 1 1)))})

(fn extract-completion-context [prefix]
  (let [root-form (extract.form {:root? true})]
    (when root-form
      (let [{: content : range} root-form
            lines (text.split-lines content)
            [row col] (vim.api.nvim_win_get_cursor 0)
            lrow (- row (core.get-in range [:start 1]))
            line-index (core.inc lrow)
            lcol (if (= lrow 0)
                     (- col (core.get-in range [:start 2]))
                     col)
            original (core.get lines line-index)
            spliced (.. (string.sub
                          original
                          1 lcol)
                        "__prefix__"
                        (string.sub
                          original
                          (core.inc lcol)))]
        (-> lines
            (core.assoc line-index spliced)
            (->> (str.join "\n")))))))

(fn enhanced-cljs-completion? []
  (cfg [:completion :cljs :use_suitable]))

(fn M.completions [opts]
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
            (->> (core.get (core.last msgs) :completions)
                 (core.map clojure->vim-completion)
                 (opts.cb))))))
    {:silent? true
     :else opts.cb}))

(fn M.out-subscribe []
  (try-ensure-conn)
  (log.append ["; Subscribing to out"] {:break? true})
  (server.with-conn-and-ops-or-warn
    [:out-subscribe]
    (fn [conn]
      (server.send {:op :out-subscribe}))))

(fn M.out-unsubscribe []
  (try-ensure-conn)
  (log.append ["; Unsubscribing from out"] {:break? true})
  (server.with-conn-and-ops-or-warn
    [:out-unsubscribe]
    (fn [conn]
      (server.send {:op :out-unsubscribe}))))

M
