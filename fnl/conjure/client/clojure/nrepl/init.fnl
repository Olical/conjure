(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local action (autoload :conjure.client.clojure.nrepl.action))
(local auto-repl (autoload :conjure.client.clojure.nrepl.auto-repl))
(local config (autoload :conjure.config))
(local debugger (autoload :conjure.client.clojure.nrepl.debugger))
(local mapping (autoload :conjure.mapping))
(local parse (autoload :conjure.client.clojure.nrepl.parse))
(local server (autoload :conjure.client.clojure.nrepl.server))
(local str (autoload :conjure.aniseed.string))
(local ts (autoload :conjure.tree-sitter))
(local util (autoload :conjure.util))

(local buf-suffix ".cljc")
(local comment-prefix "; ")
(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(local reader-macro-pairs
  [["#{" "}"]
   ["#(" ")"]
   ["#?(" ")"]
   ["'(" ")"]
   ["'[" "]"]
   ["'{" "}"]
   ["`(" ")"]
   ["`[" "]"]
   ["`{" "}"]])

(local reader-macros
  ["@"
   "^{"
   "^:"])

(fn form-node? [node]
  (or (ts.node-surrounded-by-form-pair-chars? node reader-macro-pairs)
      (ts.node-prefixed-by-chars? node reader-macros)))

(fn symbol-node? [node]
  (string.find (node:type) :kwd))

(local comment-node? ts.lisp-comment-node?)

(config.merge
  {:client
   {:clojure
    {:nrepl
     {:connection
      {:default_host "localhost"
       :port_files [".nrepl-port" ".shadow-cljs/nrepl.port"]
       :auto_repl {:enabled true
                   :hidden false
                   :cmd "bb nrepl-server localhost:$port"
                   :port_file ".nrepl-port"}}

      :eval
      {:pretty_print true
       :raw_out false
       :auto_require true
       :print_quota nil
       :print_function :conjure.internal/pprint
       :print_options {:length 500
                       :level 50
                       :right_margin 72}}

      :interrupt
      {:sample_limit 0.3}

      :refresh
      {:after nil
       :before nil
       :dirs nil
       :backend "tools.namespace"}

      :test
      {:current_form_names ["deftest"]
       :raw_out false
       :runner "clojure"
       :call_suffix nil}

      :completion
      {:cljs {:use_suitable true}
       :with_context false}

      :tap
      {:queue_size 16}}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
   {:client
    {:clojure
     {:nrepl
      {:mapping
       {:disconnect "cd"
        :connect_port_file "cf"

        :interrupt "ei"

        :last_exception "ve"
        :result_1 "v1"
        :result_2 "v2"
        :result_3 "v3"
        :view_source "vs"
        :view_tap "vt"

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
        :refresh_clear "rc"}}}}}))

(fn context [header]
  (-?> header
       (parse.strip-shebang)
       (parse.strip-meta)
       (parse.strip-comments)
       (string.match "%(%s*ns%s+([^)]*)")
       (str.split "%s+")
       (a.first)))

(fn eval-file [opts]
  (action.eval-file opts))

(fn eval-str [opts]
  (action.eval-str opts))

(fn doc-str [opts]
  (action.doc-str opts))

(fn def-str [opts]
  (action.def-str opts))

(fn completions [opts]
  (action.completions opts))

(fn connect [opts]
  (action.connect-host-port opts))

(fn on-filetype []
  (mapping.buf
    :CljDisconnect (cfg [:mapping :disconnect])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.server :disconnect)
    {:desc "Disconnect from the current REPL"})

  (mapping.buf
    :CljConnectPortFile (cfg [:mapping :connect_port_file])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :connect-port-file)
    {:desc "Connect to port specified in .nrepl-port etc"})

  (mapping.buf
    :CljInterrupt (cfg [:mapping :interrupt])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :interrupt)
    {:desc "Interrupt the current evaluation"})

  (mapping.buf
    :CljLastException (cfg [:mapping :last_exception])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :last-exception)
    {:desc "Display the last exception in the log"})

  (mapping.buf
    :CljResult1 (cfg [:mapping :result_1])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-1)
    {:desc "Display the most recent result"})

  (mapping.buf
    :CljResult2 (cfg [:mapping :result_2])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-2)
    {:desc "Display the second most recent result"})

  (mapping.buf
    :CljResult3 (cfg [:mapping :result_3])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :result-3)
    {:desc "Display the third most recent result"})

  (mapping.buf
    :CljViewSource (cfg [:mapping :view_source])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :view-source)
    {:desc "View the source of the function under the cursor"})

  (mapping.buf
    :CljSessionClone (cfg [:mapping :session_clone])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :clone-current-session)
    {:desc "Clone the current nREPL session"})

  (mapping.buf
    :CljSessionFresh (cfg [:mapping :session_fresh])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :clone-fresh-session)
    {:desc "Create a fresh nREPL session"})

  (mapping.buf
    :CljSessionClose (cfg [:mapping :session_close])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :close-current-session)
    {:desc "Close the current nREPL session"})

  (mapping.buf
    :CljSessionCloseAll (cfg [:mapping :session_close_all])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :close-all-sessions)
    {:desc "Close all nREPL sessions"})

  (mapping.buf
    :CljSessionList (cfg [:mapping :session_list])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :display-sessions)
    {:desc "List the current nREPL sessions"})

  (mapping.buf
    :CljSessionNext (cfg [:mapping :session_next])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :next-session)
    {:desc "Activate the next nREPL session"})

  (mapping.buf
    :CljSessionPrev (cfg [:mapping :session_prev])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :prev-session)
    {:desc "Activate the previous nREPL session"})

  (mapping.buf
    :CljSessionSelect (cfg [:mapping :session_select])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :select-session-interactive)
    {:desc "Prompt to select a nREPL session"})

  (mapping.buf
    :CljRunAllTests (cfg [:mapping :run_all_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-all-tests)
    {:desc "Run all loaded tests"})

  (mapping.buf
    :CljRunCurrentNsTests (cfg [:mapping :run_current_ns_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-current-ns-tests)
    {:desc "Run loaded tests in the current namespace"})

  (mapping.buf
    :CljRunAlternateNsTests (cfg [:mapping :run_alternate_ns_tests])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-alternate-ns-tests)
    {:desc "Run the tests in the *-test variant of your current namespace"})

  (mapping.buf
    :CljRunCurrentTest (cfg [:mapping :run_current_test])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :run-current-test)
    {:desc "Run the test under the cursor"})

  (mapping.buf
    :CljRefreshChanged (cfg [:mapping :refresh_changed])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-changed)
    {:desc "Refresh changed namespaces"})

  (mapping.buf
    :CljRefreshAll (cfg [:mapping :refresh_all])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-all)
    {:desc "Refresh all namespaces"})

  (mapping.buf
    :CljRefreshClear (cfg [:mapping :refresh_clear])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :refresh-clear)
    {:desc "Clear the refresh cache"})

  (mapping.buf
    :CljViewTap (cfg [:mapping :view_tap])
    (util.wrap-require-fn-call :conjure.client.clojure.nrepl.action :view-tap)
    {:desc "Show all tapped values and clear the queue"})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjureShadowSelect"
    #(action.shadow-select (a.get $ :args))
    {:force true
     :nargs 1})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjurePiggieback"
    #(action.piggieback (a.get $ :args))
    {:force true
     :nargs 1})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjureOutSubscribe"
    action.out-subscribe
    {:force true
     :nargs 0})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjureOutUnsubscribe"
    action.out-unsubscribe
    {:force true
     :nargs 0})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjureCljDebugInit"
    debugger.init
    {:force true})

  (vim.api.nvim_buf_create_user_command
    0
    "ConjureCljDebugInput"
    debugger.debug-input
    {:force true
     :nargs 1})

  (action.passive-ns-require))

(fn on-load []
  (action.connect-port-file))

(fn on-exit []
  (auto-repl.delete-auto-repl-port-file)
  (server.disconnect))

{: buf-suffix
 : comment-node?
 : comment-prefix
 : completions
 : connect
 : context
 : def-str
 : doc-str
 : eval-file
 : eval-str
 : form-node?
 : on-exit
 : on-filetype
 : on-load
 : symbol-node?}
