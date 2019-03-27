(ns conjure.dev
  "Tools used to aid the development and debugging of Conjure itself."
  (:require [clojure.core.server :as server]
            [clojure.edn :as edn]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [conjure.util :as util]))

(defn init
  "Initialise the logging and internal development prepl where required."
  []
  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :log-path)]
                         (appenders/spit-appender {:fname path}))}})
  (log/info "Logging initialised")

  (when-let [port (util/env :prepl-server-port)]
    (server/start-server {:accept 'clojure.core.server/io-prepl
                          :address "127.0.0.1"
                          :name :dev
                          :port (edn/read-string port)})
    (log/info "Started prepl server on port" port)))
