(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.edn :as edn]
            [clojure.spec.alpha :as s]
            [clojure.string :as str]
            [expound.alpha :as expound]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [conjure.util :as util]
            [conjure.rpc :as rpc]
            [conjure.prepl :as prepl]
            [conjure.ui :as ui]
            [conjure.action :as action]
            [conjure.nvim :as nvim]))

(defn- clean-up-and-exit
  "Performs any necessary clean up and calls `(System/exit status)`."
  []
  (log/info "Shutting down")
  (shutdown-agents)
  (flush)
  (binding [*out* *err*] (flush))
  (.. Runtime (getRuntime) (halt 0)))

(defn -main
  "Start up any background services and then wait forever."
  []
  (.. Runtime (getRuntime) (addShutdownHook (Thread. #(clean-up-and-exit))))

  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :log-path)]
                         (appenders/spit-appender {:fname path}))}})
  (log/info "Logging initialised")

  (rpc/init)
  (prepl/init)
  (nvim/set-ready!)
  (log/info "Everything's ready! Let's perform some magic.")
  @(promise))

(defn parse-user-edn
  "Parses some string as EDN and ensures it conforms to a spec.
  Returns nil and displays an error if it fails."
  [spec src]
  (let [value (edn/read-string {:readers {'regex re-pattern}} src)]
    (if (s/valid? spec value)
      value
      (ui/error (expound/expound-str spec value)))))

;; Here we map RPC notifications and requests to their Clojure functions.
;; Input strings are parsed as EDN and checked against specs where required.
(defmethod rpc/handle-notify :add [{:keys [params]}]
  (when-let [new-conn (parse-user-edn ::prepl/new-conn (first params))]
    (prepl/add! new-conn)))

(defmethod rpc/handle-notify :remove [{:keys [params]}]
  (when-let [tag (parse-user-edn ::prepl/tag (first params))]
    (prepl/remove! tag)))

(defmethod rpc/handle-notify :remove-all [_]
  (prepl/remove-all!))

(defmethod rpc/handle-notify :status [_]
  (prepl/status))

(defmethod rpc/handle-notify :eval [{:keys [params]}]
  (action/eval* (first params)))

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

(defmethod rpc/handle-notify :open-log [_]
  (ui/upsert-log {:focus? true
                  :resize? true
                  :size :large}))

(defmethod rpc/handle-notify :close-log [_]
  (ui/close-log))

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
