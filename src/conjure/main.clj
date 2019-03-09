(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.core.async :as a]
            [clojure.edn :as edn]
            [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]
            [conjure.pool :as pool]
            [conjure.ui :as ui]))

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

(defn -main
  "Start up any background services and then wait forever."
  []
  (dev/init)
  (rpc/init)

  (log/info "Everything's up and running")

  (let [fry (a/chan)]
    ;; https://www.youtube.com/watch?v=6UHlXLmsDGA
    ;;      __
    ;; (___()'`;
    ;; /,    /`
    ;; \\"--\\
    (a/<!! fry)))

;; Here we map RPC notifications and requests to their Clojure functions.
;; Input strings are also parsed as EDN and checked against specs where required.
(defmethod rpc/handle-notify :connect [{:keys [params]}]
  (when-let [conn (parse-user-edn ::pool/new-conn (first params))]
    (log/info conn)))
