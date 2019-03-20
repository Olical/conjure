(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.edn :as edn]
            [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.action :as action]))

(defn -main
  "Start up any background services and then wait forever."
  []
  (dev/init)
  (rpc/init))

;; So users can pass {:expr #regex "..."}
;; EDN doesn't support regular expressions out of the box.
(def edn-opts {:readers {'regex re-pattern}})

(defn parse-user-edn
  "Parses some string as EDN and ensures it conforms to a spec.
  Returns nil and displays an error if it fails."
  [spec src]
  (let [value (edn/read-string edn-opts src)]
    (if (s/valid? spec value)
      value
      (ui/error (expound/expound-str spec value)))))

;; Here we map RPC notifications and requests to their Clojure functions.
;; Input strings are parsed as EDN and checked against specs where required.
(defmethod rpc/handle-notify :add [{:keys [params]}]
  (when-let [new-conn (parse-user-edn ::pool/new-conn (first params))]
    (pool/add! new-conn)))

(defmethod rpc/handle-notify :remove [{:keys [params]}]
  (when-let [tag (parse-user-edn ::pool/tag (first params))]
    (pool/remove! tag)))

(defmethod rpc/handle-notify :remove-all [{:keys [_]}]
  (pool/remove-all!))

(defmethod rpc/handle-notify :status [{:keys [_]}]
  (pool/status))

(defmethod rpc/handle-notify :eval [{:keys [params] :as opts}]
  ;; TODO Handle ranges
  (prn opts)
  (action/eval* (first params)))

(defmethod rpc/handle-notify :eval-current-form [{:keys [_]}]
  (action/eval-current-form))

(defmethod rpc/handle-notify :eval-root-form [{:keys [_]}]
  (action/eval-root-form))

(defmethod rpc/handle-notify :doc [{:keys [params]}]
  (action/doc (first params)))

(defmethod rpc/handle-notify :open-log [_]
  (ui/upsert-log {:focus? true, :width :large}))

(defmethod rpc/handle-notify :close-log [_]
  (ui/close-log))

;; TODO goto, autocomplete, tests, reloading
