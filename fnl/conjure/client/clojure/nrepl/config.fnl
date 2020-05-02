(module conjure.client.clojure.nrepl.config)

(def connection
  {:default-host "localhost"
   :port-files [".nrepl-port" ".shadow-cljs/nrepl.port"]})

(def eval
  {:pretty-print? true})

(def debug?
  false)

(def interrupt
  {:sample-limit 0.3})

(def refresh
  {:after nil
   :before nil
   :dirs nil})

(def mappings
  {:disconnect "cd"
   :connect-port-file "cf"

   :interrupt "ei"

   :last-exception "ve"
   :result-1 "v1"
   :result-2 "v2"
   :result-3 "v3"
   :view-source "vs"

   :session-clone "sc"
   :session-fresh "sf"
   :session-close "sq"
   :session-close-all "sQ"
   :session-list "sl"
   :session-next "sn"
   :session-prev "sp"
   :session-select "ss"
   :session-type "st"

   :run-all-tests "ta"
   :run-current-ns-tests "tn"
   :run-alternate-ns-tests "tN"
   :run-current-test "tc"

   :refresh-changed "rr"
   :refresh-all "ra"
   :refresh-clear "rc"})
