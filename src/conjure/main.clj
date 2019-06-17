(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.string :as str]
            [clojure.java.shell :as shell]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [me.raynes.fs :as fs]
            [conjure.config :as config]
            [conjure.util :as util]
            [conjure.rpc :as rpc]
            [conjure.prepl :as prepl]
            [conjure.ui :as ui]
            [conjure.action :as action]
            [conjure.nvim :as nvim]))

(defn- clean-up-and-exit []
  (log/info "Shutting down")
  (shutdown-agents)
  (flush)
  (binding [*out* *err*] (flush))
  (.. Runtime (getRuntime) (halt 0)))

(defonce exit-handle! (promise))

(defn -main
  "Start up any background services and then wait until the exit promise is delivered."
  [cwd]
  (.. Runtime (getRuntime) (addShutdownHook (Thread. #(clean-up-and-exit))))

  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :conjure-log-path)]
                         (appenders/spit-appender {:fname (str (fs/file cwd path))}))}})
  (log/info "Logging initialised")

  (log/info (str "System versions\n" (:out (shell/sh "bin/versions"))))

  (rpc/init)
  (prepl/init)
  (nvim/set-ready!)
  (log/info "Everything's ready! Let's perform some magic.")
  @exit-handle!)

;; Here we map RPC notifications and requests to their Clojure functions.
(defmethod rpc/handle-notify :up [{:keys [params]}]
  (-> (config/fetch {:flags (first params)
                     :cwd (nvim/cwd)})
      (get :conns)
      (prepl/sync!)))

(defmethod rpc/handle-notify :status [_]
  (prepl/status))

(defmethod rpc/handle-notify :eval [{:keys [params]}]
  (action/eval* {:code (first params)
                 :line (nvim/current-line)}))

(defmethod rpc/handle-notify :eval-current-form [_]
  (action/eval-current-form))

(defmethod rpc/handle-notify :eval-root-form [_]
  (action/eval-root-form))

(defmethod rpc/handle-notify :eval-selection [_]
  (action/eval-selection))

(defmethod rpc/handle-notify :eval-buffer [_]
  (action/eval-buffer))

(defmethod rpc/handle-notify :load-file [{:keys [params]}]
  (action/load-file* (first params)))

(defmethod rpc/handle-notify :doc [{:keys [params]}]
  (action/doc (first params)))

(defmethod rpc/handle-notify :quick-doc [_]
  (action/quick-doc))

(def ^:private log-opts
  {:focus? true
   :resize? true
   :size :large})

(defmethod rpc/handle-notify :open-log [_]
  (ui/upsert-log log-opts))

(defmethod rpc/handle-notify :close-log [_]
  (ui/close-log))

(defmethod rpc/handle-notify :toggle-log [_]
  (if (ui/log-open?)
    (ui/close-log)
    (ui/upsert-log log-opts)))

(defmethod rpc/handle-request :completions [{:keys [params]}]
  (action/completions (first params)))

(defmethod rpc/handle-request :get-rpc-port [_]
  rpc/port)

(defmethod rpc/handle-notify :definition [{:keys [params]}]
  (action/definition (first params)))

(defmethod rpc/handle-notify :run-tests [{:keys [params]}]
  (action/run-tests (->> (str/split (first params) #"\s+")
                         (remove str/blank?))))

(defmethod rpc/handle-notify :run-all-tests [{:keys [params]}]
  (action/run-all-tests (when-not (str/blank? (first params))
                          (first params))))

(defmethod rpc/handle-notify :stop [_]
  (deliver exit-handle! true))
