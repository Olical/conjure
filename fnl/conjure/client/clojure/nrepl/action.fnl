(module conjure.client.clojure.nrepl.action
  {require {client conjure.client
            text conjure.text
            extract conjure.extract
            editor conjure.editor
            ll conjure.linked-list
            eval conjure.aniseed.eval
            str conjure.aniseed.string
            nvim conjure.aniseed.nvim
            view conjure.aniseed.view
            config conjure.client.clojure.nrepl.config
            state conjure.client.clojure.nrepl.state
            server conjure.client.clojure.nrepl.server
            ui conjure.client.clojure.nrepl.ui
            a conjure.aniseed.core}})

(defn display-session-type []
  (server.eval
    {:code (.. "#?("
               (str.join
                 " "
                 [":clj 'Clojure"
                  ":cljs 'ClojureScript"
                  ":cljr 'ClojureCLR"
                  ":default 'Unknown"])
               ")")}
    (server.with-all-msgs-fn
      (fn [msgs]
        (ui.display [(.. "; Session type: " (a.get (a.first msgs) :value))]
                    {:break? true})))))

(defn connect-port-file []
  (let [port (-?> (a.some a.slurp [".nrepl-port" ".shadow-cljs/nrepl.port"]) (tonumber))]
    (if port
      (server.connect
        {:host config.connection.default-host
         :port port})
      (ui.display ["; No nREPL port file found"] {:break? true}))))

(defn connect-host-port [...]
  (let [args [...]]
    (server.connect
      {:host (if (= 1 (a.count args))
               config.connection.default-host
               (a.first args))
       :port (tonumber (a.last args))})))

(defn eval-str [opts]
  (server.with-conn-or-warn
    (fn [_]
      (server.eval
        {:code (.. "(in-ns '" (or opts.context "user") ")")}
        (fn []))
      (server.eval opts (or opts.cb #(ui.display-result $1 opts))))))

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
          (f (when (not (server.status= msg :no-info))
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
  (server.eval
    (a.merge
      {} opts
      {:code (.. "(do (require 'clojure.repl)"
                 "(clojure.repl/doc " opts.code "))")})
    (server.with-all-msgs-fn
      (fn [msgs]
        (if (and (= 2 (a.count msgs))
                 (= "nil" (a.get (a.first msgs) :value)))
          (do
            (ui.display ["; No results, checking CIDER's info op"])
            (with-info
              opts
              (fn [info]
                (if
                  (a.nil? info)
                  (ui.display ["; Nothing found via CIDER's info either"])

                  info.javadoc
                  (ui.display (java-info->lines info))

                  (ui.display
                    (a.concat
                      ["; Unknown result, it may still be helpful"]
                      (text.prefixed-lines (view.serialise info) "; ")))))))
          (a.run!
            #(ui.display-result
               $1
               {:simple-out? true :ignore-nil? true})
            msgs))))))

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
  (with-info
    opts
    (fn [info]
      (if
        (a.nil? info)
        (ui.display ["; No definition information found"])

        info.candidates
        (ui.display
          (a.concat
            ["; Multiple candidates found"]
            (a.map #(.. $1 "/" opts.code) (a.keys info.candidates))))

        info.javadoc
        (ui.display ["; Can't open source, it's Java"
                     (.. "; " info.javadoc)])

        info.special-form
        (ui.display ["; Can't open source, it's a special form"
                     (when info.url (.. "; " info.url))])

        (and info.file info.line)
        (let [column (or info.column 1)
              path (nrepl->nvim-path info.file)]
          (editor.go-to path info.line column)
          (ui.display [(.. "; " path " [" info.line " " column "]") ]))

        (ui.display ["; Unsupported target"
                     (.. "; " (a.pr-str info))])))))

(defn eval-file [opts]
  (server.eval
    (a.assoc opts :code (.. "(load-file \"" opts.file-path "\")"))
    #(ui.display-result $1 opts)))

(defn interrupt []
  (server.with-conn-or-warn
    (fn [conn]
      (let [msgs (->> (a.vals conn.msgs)
                      (a.filter
                        (fn [msg]
                          (= :eval msg.msg.op))))]
        (if (a.empty? msgs)
          (ui.display ["; Nothing to interrupt"] {:break? true})
          (do
            (table.sort
              msgs
              (fn [a b]
                (< a.sent-at b.sent-at)))
            (let [oldest (a.first msgs)]
              (server.send {:op :interrupt
                            :id oldest.msg.id
                            :session oldest.msg.session})
              (ui.display
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
      (ui.display [(.. "; source (word): " word)] {:break? true})
      (eval-str
        {:code (.. "(require 'clojure.repl)"
                   "(clojure.repl/source " word ")")
         :context (extract.context)
         :cb #(ui.display-result
                $1
                {:raw-out? true
                 :ignore-nil? true})}))))

(defn clone-current-session []
  (server.with-conn-or-warn
    (fn [conn]
      (server.clone-session (a.get conn :session)))))

(defn clone-fresh-session []
  (server.with-conn-or-warn
    (fn [conn]
      (server.clone-session))))

(defn close-current-session []
  (server.with-conn-or-warn
    (fn [conn]
      (let [session (a.get conn :session)]
        (a.assoc conn :session nil)
        (ui.display [(.. "; Closed current session: " session)]
                    {:break? true})
        (server.close-session
          session server.assume-or-create-session)))))

(defn display-sessions [cb]
  (server.with-sessions
    (fn [sessions]
      (ui.display-given-sessions sessions cb))))

(defn close-all-sessions []
  (server.with-sessions
    (fn [sessions]
      (a.run! server.close-session sessions)
      (ui.display [(.. "; Closed all sessions (" (a.count sessions)")")]
                  {:break? true})
      (server.clone-session))))

(defn- cycle-session [f]
  (server.with-conn-or-warn
    (fn [conn]
      (server.with-sessions
        (fn [sessions]
          (if (= 1 (a.count sessions))
            (ui.display ["; No other sessions"] {:break? true})
            (let [session (a.get conn :session)]
              (->> sessions
                   (ll.create)
                   (ll.cycle)
                   (ll.until #(f session $1))
                   (ll.val)
                   (server.assume-session)))))))))

(defn next-session []
  (cycle-session
    (fn [current node]
      (= current (->> node (ll.prev) (ll.val))))))

(defn prev-session []
  (cycle-session
    (fn [current node]
      (= current (->> node (ll.next) (ll.val))))))

(defn select-session-interactive []
  (server.with-sessions
    (fn [sessions]
      (if (= 1 (a.count sessions))
        (ui.display ["; No other sessions"] {:break? true})
        (ui.display-given-sessions
          sessions
          (fn []
            (nvim.ex.redraw_)
            (let [n (nvim.fn.str2nr (extract.prompt "Session number: "))]
              (if (<= 1 n (a.count sessions))
                (server.assume-session (a.get sessions n))
                (ui.display ["; Invalid session number."])))))))))

(defn run-all-tests []
  (ui.display ["; run-all-tests"] {:break? true})
  (server.eval
    {:code "(require 'clojure.test) (clojure.test/run-all-tests)"}
    #(ui.display-result
       $1
       {:simple-out? true
        :ignore-nil? true})))

(defn- run-ns-tests [ns]
  (when ns
    (ui.display [(.. "; run-ns-tests: " ns)]
                {:break? true})
    (server.eval
      {:code (.. "(require 'clojure.test)"
                 "(clojure.test/run-tests '" ns ")")}
      #(ui.display-result
         $1
         {:simple-out? true
          :ignore-nil? true}))))

(defn run-current-ns-tests []
  (run-ns-tests (extract.context)))

(defn run-alternate-ns-tests []
  (let [current-ns (extract.context)]
    (run-ns-tests
      (if (text.ends-with current-ns "-test")
        (string.sub current-ns 1 -6)
        (.. current-ns "-test")))))

(defn run-current-test []
  (let [form (extract.form {:root? true})]
    (when form
      (let [(test-name sub-count)
            (string.gsub form.content ".*deftest%s+(.-)%s+.*" "%1")]
        (when (and (not (a.empty? test-name)) (= 1 sub-count))
          (ui.display [(.. "; run-current-test: " test-name)]
                      {:break? true})
          (server.eval
            {:code (.. "(do (require 'clojure.test)"
                       "    (clojure.test/test-var"
                       "      (resolve '" test-name ")))")}
            (server.with-all-msgs-fn
              (fn [msgs]
                (if (and (= 2 (a.count msgs))
                         (= "nil" (a.get (a.first msgs) :value)))
                  (ui.display ["; Success!"])
                  (a.run! #(ui.display-result
                             $1
                             {:simple-out? true
                              :ignore-nil? true})
                          msgs))))))))))

(defn- refresh-impl [op]
  (server.with-conn-and-op-or-warn
    op
    (fn [conn]
      (server.send
        (a.merge
          {:op op
           :session conn.session}
          (a.get config :refresh))
        (fn [msg]
          (if
            msg.reloading
            (ui.display msg.reloading)

            msg.error
            (ui.display [(.. "; Error while reloading "
                             msg.error-ns)])

            (server.status= msg :ok)
            (ui.display ["; Refresh complete"])

            (server.status= msg :done)
            nil

            (ui.display-result msg {})))))))

(defn refresh-changed []
  (ui.display ["; Refreshing changed namespaces"] {:break? true})
  (refresh-impl :refresh))

(defn refresh-all []
  (ui.display ["; Refreshing all namespaces"] {:break? true})
  (refresh-impl :refresh-all))

(defn refresh-clear []
  (ui.display ["; Clearing refresh state"] {:break? true})
  (server.with-conn-and-op-or-warn
    :refresh-clear
    (fn [conn]
      (server.send
        {:op :refresh-clear
         :session conn.session}
        (server.with-all-msgs-fn
          (fn [msgs]
            (ui.display ["; Clearing complete"])))))))

(defn shadow-select [build]
  (server.with-conn-or-warn
    (fn [conn]
      (ui.display [(.. "; shadow-cljs (select): " build)] {:break? true})
      (server.eval
        {:code (.. "(shadow.cljs.devtools.api/nrepl-select :" build ")")}
        #(ui.display-result $1 {})))))

(defn piggieback [code]
  (server.with-conn-or-warn
    (fn [conn]
      (ui.display [(.. "; piggieback: " code)] {:break? true})
      (server.eval
        {:code (.. "(do (require 'cider.piggieback)"
                   "(cider.piggieback/cljs-repl " code "))")}
        #(ui.display-result $1 {})))))

(defn- abbr-ns [ns]
 ns)

(defn- clojure->vim-completion [{:candidate word
                                 :type kind
                                 : ns
                                 :doc info
                                 : arglists}]
  {:word word
   :abbr (str.join
           " "
           (a.concat
             [word]
             (when arglists
               [(str.join " " arglists)])))
   :menu (abbr-ns ns)
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

(defn completions [opts]
  (server.with-conn-and-op-or-warn
    :complete
    (fn [conn]
      (a.println (extract-completion-context opts.prefix))
      (server.send
        {:op :complete
         :ns opts.context
         :symbol opts.prefix
         :context (extract-completion-context opts.prefix)
         :extra-metadata [:arglists :doc]}
        (server.with-all-msgs-fn
          (fn [msgs]
            (->> (a.get (a.last msgs) :completions)
                 (a.map clojure->vim-completion)
                 (opts.cb))))))))
