(module conjure.client.clojure.nrepl
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             mapping conjure.mapping
             eval conjure.eval
             str conjure.aniseed.string
             text conjure.text
             config conjure.config
             action conjure.client.clojure.nrepl.action
             server conjure.client.clojure.nrepl.server
             parse conjure.client.clojure.nrepl.parse
             debugger conjure.client.clojure.nrepl.debugger
             client conjure.client
             util conjure.util
             ts conjure.tree-sitter}})

(def buf-suffix ".cljc")
(def comment-prefix "; ")
(def- cfg (config.get-in-fn [:client :clojure :nrepl]))

(def- reader-macro-pairs
  [["#{" "}"]
   ["#(" ")"]
   ["#?(" ")"]
   ["'(" ")"]
   ["'[" "]"]
   ["'{" "}"]
   ["`(" ")"]
   ["`[" "]"]
   ["`{" "}"]])

(defn form-node? [node]
  (ts.node-surrounded-by-form-pair-chars? node reader-macro-pairs))

(def comment-node? ts.lisp-comment-node?)

(config.merge
  {:client
   {:clojure
    {:nrepl
     {:connection
      {:default_host "localhost"
       :port_files [".nrepl-port" ".shadow-cljs/nrepl.port"]
       :auto_repl {:enabled true
                   :hidden false
                   :cmd "bb nrepl-server localhost:8794"
                   :port_file ".nrepl-port" :port "8794"}}

      :eval
      {:pretty_print true
       :raw_out false
       :auto_require true
       :print_quota nil
       :print_function :conjure.internal/pprint
       :print_options {:length 500 :level 50}}

      :interrupt
      {:sample_limit 0.3}

      :refresh
      {:after nil
       :before nil
       :dirs nil}

      :test
      {:current_form_names ["deftest"]
       :raw_out false
       :runner "clojure"
       :call_suffix nil}

      :mapping
      {:disconnect "cd"
       :connect_port_file "cf"

       :interrupt "ei"

       :last_exception "ve"
       :result_1 "v1"
       :result_2 "v2"
       :result_3 "v3"
       :view_source "vs"

       :session_clone "sc"
       :session_fresh "sf"
       :session_close "sq"
       :session_close_all "sQ"
       :session_list "sl"
       :session_next "sn"
       :session_prev "sp"
       :session_select "ss"

       :run_all_tests "ta"
       :run_current_ns_tests "tn"
       :run_alternate_ns_tests "tN"
       :run_current_test "tc"

       :refresh_changed "rr"
       :refresh_all "ra"
       :refresh_clear "rc"}

      :completion
      {:cljs {:use_suitable true}
       :with_context false}}}}})

(defn context [header]
  (-?> header
       (parse.strip-shebang)
       (parse.strip-meta)
       (parse.strip-comments)
       (string.match "%(%s*ns%s+([^)]*)")
       (str.split "%s+")
       (a.first)))

(defn eval-file [opts]
  (action.eval-file opts))

(defn eval-str [opts]
  (action.eval-str opts))

(defn doc-str [opts]
  (action.doc-str opts))

(defn def-str [opts]
  (action.def-str opts))

(defn completions [opts]
  (action.completions opts))

(defn connect [opts]
  (action.connect-host-port opts))

(defn on-filetype []
  (mapping.buf2
    :CljDisconnect (cfg [:mapping :disconnect])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.server :disconnect)
    {:desc "Disconnect from the current REPL"})

  (mapping.buf2
    :CljConnectPortFile (cfg [:mapping :connect_port_file])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :connect-port-file)
    {:desc "Connect to port specified in .nrepl-port etc"})

  (mapping.buf2
    :CljInterrupt (cfg [:mapping :interrupt])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :interrupt)
    {:desc "Interrupt the current evaluation"})

  (mapping.buf2
    :CljLastException (cfg [:mapping :last_exception])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :last-exception)
    {:desc "Display the last exception in the log"})

  (mapping.buf2
    :CljResult1 (cfg [:mapping :result_1])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-1)
    {:desc "Display the most recent result"})

  (mapping.buf2
    :CljResult2 (cfg [:mapping :result_2])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-2)
    {:desc "Display the second most recent result"})

  (mapping.buf2
    :CljResult3 (cfg [:mapping :result_3])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-3)
    {:desc "Display the third most recent result"})

  (mapping.buf2
    :CljViewSource (cfg [:mapping :view_source])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :view-source)
    {:desc "View the source of the function under the cursor"})

  (mapping.buf2
    :CljSessionClone (cfg [:mapping :session_clone])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :clone-current-session)
    {:desc "Clone the current nREPL session"})

  (mapping.buf2
    :CljSessionFresh (cfg [:mapping :session_fresh])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :clone-fresh-session)
    {:desc "Create a fresh nREPL session"})

  (mapping.buf2
    :CljSessionClose (cfg [:mapping :session_close])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :close-current-session)
    {:desc "Close the current nREPL session"})

  (mapping.buf2
    :CljSessionCloseAll (cfg [:mapping :session_close_all])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :close-all-sessions)
    {:desc "Close all nREPL sessions"})

  (mapping.buf2
    :CljSessionList (cfg [:mapping :session_list])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :display-sessions)
    {:desc "List the current nREPL sessions"})

  (mapping.buf2
    :CljSessionNext (cfg [:mapping :session_next])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :next-session)
    {:desc "Activate the next nREPL session"})

  (mapping.buf2
    :CljSessionPrev (cfg [:mapping :session_prev])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :prev-session)
    {:desc "Activate the previous nREPL session"})

  (mapping.buf2
    :CljSessionSelect (cfg [:mapping :session_select])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :select-session-interactive)
    {:desc "Prompt to select a nREPL session"})

  (mapping.buf2
    :CljRunAllTests (cfg [:mapping :run_all_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-all-tests)
    {:desc "Run all loaded tests"})

  (mapping.buf2
    :CljRunCurrentNsTests (cfg [:mapping :run_current_ns_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-current-ns-tests)
    {:desc "Run loaded tests in the current namespace"})

  (mapping.buf2
    :CljRunAlternateNsTests (cfg [:mapping :run_alternate_ns_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-alternate-ns-tests)
    {:desc "Run the tests in the *-test variant of your current namespace"})

  (mapping.buf2
    :CljRunCurrentTest (cfg [:mapping :run_current_test])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-current-test)
    {:desc "Run the test under the cursor"})

  (mapping.buf2
    :CljRefreshChanged (cfg [:mapping :refresh_changed])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-changed)
    {:desc "Refresh changed namespaces"})

  (mapping.buf2
    :CljRefreshAll (cfg [:mapping :refresh_all])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-all)
    {:desc "Refresh all namespaces"})

  (mapping.buf2
    :CljRefreshClear (cfg [:mapping :refresh_clear])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-clear)
    {:desc "Clear the refresh cache"})

  (nvim.buf_create_user_command
    0
    "ConjureShadowSelect"
    #(action.shadow-select (a.get $ :args))
    {:force true
     :nargs 1})

  (nvim.buf_create_user_command
    0
    "ConjurePiggieback"
    #(action.piggieback (a.get $ :args))
    {:force true
     :nargs 1})

  (nvim.buf_create_user_command
    0
    "ConjureOutSubscribe"
    action.out-subscribe
    {:force true
     :nargs 0})

  (nvim.buf_create_user_command
    0
    "ConjureOutUnsubscribe"
    action.out-unsubscribe
    {:force true
     :nargs 0})

  (nvim.buf_create_user_command
    0
    "ConjureCljDebugInit"
    debugger.init
    {:force true})

  (nvim.buf_create_user_command
    0
    "ConjureCljDebugInput"
    debugger.debug-input
    {:force true
     :nargs 1})

  (action.passive-ns-require))

(defn on-load []
  (action.connect-port-file))

(defn on-exit []
  (action.delete-auto-repl-port-file)
  (server.disconnect))
