(ns conjure.dev
  "Tools used to aid the development and debugging of Conjure itself."
  (:require [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [conjure.util :as util]))

(defn init
  "Initialise the logging where required."
  []
  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :log-path)]
                         (appenders/spit-appender {:fname path}))}})
  (log/info "Logging initialised"))
