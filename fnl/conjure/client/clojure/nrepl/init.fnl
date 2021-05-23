(module conjure.client.clojure.nrepl
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             mapping conjure.mapping
             bridge conjure.bridge
             eval conjure.eval
             str conjure.aniseed.string
             config conjure.config
             action conjure.client.clojure.nrepl.action
             server conjure.client.clojure.nrepl.server
             parse conjure.client.clojure.nrepl.parse
             client conjure.client}})

(def buf-suffix ".cljc")
(def comment-prefix "; ")
(def- cfg (config.get-in-fn [:client :clojure :nrepl]))

(config.merge
  {:client
   {:clojure
    {:nrepl
     {:connection
      {:default_host "localhost"
       :port_files [".nrepl-port" ".shadow-cljs/nrepl.port"]
       :auto_repl {:enabled true
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
       (parse.strip-meta)
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
  (mapping.buf :n :CljDisconnect (cfg [:mapping :disconnect])
               :conjure.client.clojure.nrepl.server :disconnect)
  (mapping.buf :n :CljConnectPortFile (cfg [:mapping :connect_port_file])
               :conjure.client.clojure.nrepl.action :connect-port-file)
  (mapping.buf :n :CljInterrupt (cfg [:mapping :interrupt])
               :conjure.client.clojure.nrepl.action :interrupt)

  (mapping.buf :n :CljLastException (cfg [:mapping :last_exception])
               :conjure.client.clojure.nrepl.action :last-exception)
  (mapping.buf :n :CljResult1 (cfg [:mapping :result_1])
               :conjure.client.clojure.nrepl.action :result-1)
  (mapping.buf :n :CljResult2 (cfg [:mapping :result_2])
               :conjure.client.clojure.nrepl.action :result-2)
  (mapping.buf :n :CljResult3 (cfg [:mapping :result_3])
               :conjure.client.clojure.nrepl.action :result-3)
  (mapping.buf :n :CljViewSource (cfg [:mapping :view_source])
               :conjure.client.clojure.nrepl.action :view-source)

  (mapping.buf :n :CljSessionClone (cfg [:mapping :session_clone])
               :conjure.client.clojure.nrepl.action :clone-current-session)
  (mapping.buf :n :CljSessionFresh (cfg [:mapping :session_fresh])
               :conjure.client.clojure.nrepl.action :clone-fresh-session)
  (mapping.buf :n :CljSessionClose (cfg [:mapping :session_close])
               :conjure.client.clojure.nrepl.action :close-current-session)
  (mapping.buf :n :CljSessionCloseAll (cfg [:mapping :session_close_all])
               :conjure.client.clojure.nrepl.action :close-all-sessions)
  (mapping.buf :n :CljSessionList (cfg [:mapping :session_list])
               :conjure.client.clojure.nrepl.action :display-sessions)
  (mapping.buf :n :CljSessionNext (cfg [:mapping :session_next])
               :conjure.client.clojure.nrepl.action :next-session)
  (mapping.buf :n :CljSessionPrev (cfg [:mapping :session_prev])
               :conjure.client.clojure.nrepl.action :prev-session)
  (mapping.buf :n :CljSessionSelect (cfg [:mapping :session_select])
               :conjure.client.clojure.nrepl.action :select-session-interactive)

  (mapping.buf :n :CljRunAllTests (cfg [:mapping :run_all_tests])
               :conjure.client.clojure.nrepl.action :run-all-tests)
  (mapping.buf :n :CljRunCurrentNsTests (cfg [:mapping :run_current_ns_tests])
               :conjure.client.clojure.nrepl.action :run-current-ns-tests)
  (mapping.buf :n :CljRunAlternateNsTests (cfg [:mapping :run_alternate_ns_tests])
               :conjure.client.clojure.nrepl.action :run-alternate-ns-tests)
  (mapping.buf :n :CljRunCurrentTest (cfg [:mapping :run_current_test])
               :conjure.client.clojure.nrepl.action :run-current-test)

  (mapping.buf :n :CljRefreshChanged (cfg [:mapping :refresh_changed])
               :conjure.client.clojure.nrepl.action :refresh-changed)
  (mapping.buf :n :CljRefreshAll (cfg [:mapping :refresh_all])
               :conjure.client.clojure.nrepl.action :refresh-all)
  (mapping.buf :n :CljRefreshClear (cfg [:mapping :refresh_clear])
               :conjure.client.clojure.nrepl.action :refresh-clear)

  (nvim.ex.command_
    "-nargs=1 -buffer ConjureShadowSelect"
    (bridge.viml->lua
      :conjure.client.clojure.nrepl.action :shadow-select
      {:args "<f-args>"}))

  (nvim.ex.command_
    "-nargs=1 -buffer ConjurePiggieback"
    (bridge.viml->lua
      :conjure.client.clojure.nrepl.action :piggieback
      {:args "<f-args>"}))

  (nvim.ex.command_
    "-nargs=0 -buffer ConjureOutSubscribe"
    (bridge.viml->lua :conjure.client.clojure.nrepl.action :out-subscribe {}))

  (nvim.ex.command_
    "-nargs=0 -buffer ConjureOutUnsubscribe"
    (bridge.viml->lua :conjure.client.clojure.nrepl.action :out-unsubscribe {}))

  (action.passive-ns-require))

(defn on-load []
  (action.connect-port-file))

(defn on-exit []
  (action.delete-auto-repl-port-file)
  (server.disconnect))
