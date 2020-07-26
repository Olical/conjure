(module conjure.client.clojure.nrepl
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            mapping conjure.mapping
            bridge conjure.bridge
            eval conjure.eval
            str conjure.aniseed.string
            config conjure.config
            action conjure.client.clojure.nrepl.action
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
       :port_files [".nrepl-port" ".shadow-cljs/nrepl.port"]}

      :eval
      {:pretty_print true
       :auto_require true
       :print_quota nil
       :print_function :conjure.internal/pprint
       :print_options {:length 500
                       :level 50}}

      :interrupt
      {:sample_limit 0.3}

      :refresh
      {:after nil
       :before nil
       :dirs nil}

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
      {:cljs {:use_suitable true}}}}}})


(defn context [header]
  (-?> header
       (string.match "%(%s*ns%s+([^)]*)")
       (string.gsub "%^:.-%s+" "")
       (string.gsub "%^%b{}%s+" "")
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
  (mapping.buf :n (cfg [:mapping :disconnect])
               :conjure.client.clojure.nrepl.server :disconnect)
  (mapping.buf :n (cfg [:mapping :connect_port_file])
               :conjure.client.clojure.nrepl.action :connect-port-file)
  (mapping.buf :n (cfg [:mapping :interrupt])
               :conjure.client.clojure.nrepl.action :interrupt)

  (mapping.buf :n (cfg [:mapping :last_exception])
               :conjure.client.clojure.nrepl.action :last-exception)
  (mapping.buf :n (cfg [:mapping :result_1])
               :conjure.client.clojure.nrepl.action :result-1)
  (mapping.buf :n (cfg [:mapping :result_2])
               :conjure.client.clojure.nrepl.action :result-2)
  (mapping.buf :n (cfg [:mapping :result_3])
               :conjure.client.clojure.nrepl.action :result-3)
  (mapping.buf :n (cfg [:mapping :view_source])
               :conjure.client.clojure.nrepl.action :view-source)

  (mapping.buf :n (cfg [:mapping :session_clone])
               :conjure.client.clojure.nrepl.action :clone-current-session)
  (mapping.buf :n (cfg [:mapping :session_fresh])
               :conjure.client.clojure.nrepl.action :clone-fresh-session)
  (mapping.buf :n (cfg [:mapping :session_close])
               :conjure.client.clojure.nrepl.action :close-current-session)
  (mapping.buf :n (cfg [:mapping :session_close_all])
               :conjure.client.clojure.nrepl.action :close-all-sessions)
  (mapping.buf :n (cfg [:mapping :session_list])
               :conjure.client.clojure.nrepl.action :display-sessions)
  (mapping.buf :n (cfg [:mapping :session_next])
               :conjure.client.clojure.nrepl.action :next-session)
  (mapping.buf :n (cfg [:mapping :session_prev])
               :conjure.client.clojure.nrepl.action :prev-session)
  (mapping.buf :n (cfg [:mapping :session_select])
               :conjure.client.clojure.nrepl.action :select-session-interactive)

  (mapping.buf :n (cfg [:mapping :run_all_tests])
               :conjure.client.clojure.nrepl.action :run-all-tests)
  (mapping.buf
    :n (cfg [:mapping :run_current_ns_tests])
    :conjure.client.clojure.nrepl.action :run-current-ns-tests)
  (mapping.buf
    :n (cfg [:mapping :run_alternate_ns_tests])
    :conjure.client.clojure.nrepl.action :run-alternate-ns-tests)
  (mapping.buf :n (cfg [:mapping :run_current_test])
               :conjure.client.clojure.nrepl.action :run-current-test)

  (mapping.buf :n (cfg [:mapping :refresh_changed])
               :conjure.client.clojure.nrepl.action :refresh-changed)
  (mapping.buf :n (cfg [:mapping :refresh_all])
               :conjure.client.clojure.nrepl.action :refresh-all)
  (mapping.buf :n (cfg [:mapping :refresh_clear])
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
