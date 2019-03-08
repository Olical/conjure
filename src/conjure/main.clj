(ns conjure.main
  (:require [msgpack.core :as msg]
            [msgpack.clojure-extensions]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]))

(defn -main []
  (dev/init!)

  (log/info "Waiting for RPC input...")
  (loop []
    (when-let [msg (msg/unpack System/in)]
      (log/trace "->" msg)
      (recur))))
