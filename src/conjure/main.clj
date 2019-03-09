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

(defn parse-user-edn [spec src]
  (let [value (edn/read-string src)]
    (if (s/valid? spec value)
      value
      (ui/error (expound/expound-str spec value)))))

(defmethod rpc/handle-notify :connect [{:keys [params]}]
  (when-let [conn (parse-user-edn ::pool/new-conn (first params))]
    (log/info conn)))

(defn -main []
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
