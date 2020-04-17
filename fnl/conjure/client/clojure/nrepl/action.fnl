(module conjure.client.clojure.nrepl.action
  {require {client conjure.client
            text conjure.text
            extract conjure.extract
            editor conjure.editor
            ll conjure.linked-list
            eval conjure.aniseed.eval
            str conjure.aniseed.string
            nvim conjure.aniseed.nvim
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

(defn- render-doc-str [{: ns : class : name : member
                        :doc docs
                        :arglists-str args
                        :type kind}]
  (let [prefix (or ns class)
        suffix (or name member)]
    (a.concat
      [(str.join
         [(when args
            "(")
          (when prefix
            (.. prefix "/"))
          suffix
          (when args
            (.. " " (str.join " " (text.split-lines args))))
          (when args
            ")")])]
      (when (and (a.string? docs) (not (a.empty? docs)))
        (text.prefixed-lines docs "; ")))))

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

(defn doc-str [opts]
  (with-info
    opts
    (fn [info]
      (ui.display
        (if
          (a.nil? info)
          ["; No documentation found"]

          info.candidates
          (a.concat
            ["; Multiple candidates found"]
            (a.map #(.. $1 "/" opts.code) (a.keys info.candidates)))

          (render-doc-str info))))))

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
       :cb (server.with-all-msgs-fn
             (fn [msgs]
               (let [val (a.get (a.first msgs) :value)
                     (ok? res) (when val
                                 (eval.str val))]
                 (if ok?
                   (let [[path line column] res]
                     (editor.go-to (jar->zip path) line column))
                   (ui.display ["; Couldn't find definition."])))))})))

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
        {:code (.. "(do (require 'clojure.repl)"
                   "(clojure.repl/source " word "))")
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
                       "(clojure.test/test-var"
                       "  (resolve '" test-name ")))")}
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
