(ns conjure.main
  (:require [clojure.core.server :as server]
            [clojure.edn :as edn]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]))

(defn configure-timbre! [{:keys [path]}]
  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when path
                         (appenders/spit-appender {:fname path}))}})
  (log/info "Logging initialised"))

(defn start-prepl-server! [{:keys [port]}]
  (server/start-server {:accept 'clojure.core.server/io-prepl
                        :address "127.0.0.1"
                        :name :dev
                        :port port})
  (log/info "Started prepl server on port" port))

(defn -main []
  (configure-timbre! {:path (System/getenv "CONJURE_LOG_PATH")})

  (when-let [port (System/getenv "CONJURE_PREPL_SERVER_PORT")]
    (start-prepl-server! {:port (edn/read-string port)}))

  (log/info "Waiting for RPC input...")
  (loop []
    (when-let [msg (msg/unpack System/in)]
      (log/trace "->" msg)
      (recur))))
