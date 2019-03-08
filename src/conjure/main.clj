(ns conjure.main
  (:require [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]))

;; Prevent anyone writing to *out* since that's for msgpack-rpc.
(alter-var-root #'*out* (constantly *err*))

(defn -main []
  (dev/init!)
  (rpc/init!)
  (log/info "Reached end of -main, exiting"))
