(module conjure.client.clojure.nrepl.config)

(def connection
  {:default-host "localhost"})

(def debug?
  false)

(def interrupt
  {:sample-limit 0.3})

(def mappings
  {:disconnect "cd"
   :connect-port-file "cf"

   :interrupt "ei"
   :last-exception "ex"
   :result-1 "e1"
   :result-2 "e2"
   :result-3 "e3"
   :view-source "es"

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
   :run-current-test "tc"})
