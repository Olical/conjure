(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.core.async :as a]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]
            [conjure.pool :as pool]
            [conjure.util :as util]))

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

(defmethod rpc/handle-notify :connect [{:keys [params]}]
  (when-let [conn (util/parse-user-edn ::pool/new-conn (first params))]
    (log/info conn)))
