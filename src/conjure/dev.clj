(ns conjure.dev
  (:require [clojure.core.server :as server]
            [clojure.spec.alpha :as s]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [conjure.util :as util]))

(s/def ::port integer?)

(defn init! []
  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :log-path)]
                         (appenders/spit-appender {:fname path}))}})
  (log/info "Logging initialised")

  (when-let [port (util/env ::port :prepl-server-port)]
    (server/start-server {:accept 'clojure.core.server/io-prepl
                          :address "127.0.0.1"
                          :name :dev
                          :port port})
    (log/info "Started prepl server on port" port)))
