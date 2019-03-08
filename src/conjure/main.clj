(ns conjure.main
  (:require [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]))

(defn -main []
  (dev/init!)
  (rpc/init!)
  (log/info "Reached end of -main, exiting"))
