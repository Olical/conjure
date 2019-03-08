(ns conjure.main
  (:require [clojure.core.async :as a]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]))

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

(defmethod rpc/handle-request :ping [{:keys [params]}]
  (into ["pong"] params))
(defmethod rpc/handle-notify :henlo [{:keys [params]}]
  (log/info "Henlo!" params)
  (rpc/request :nvim-out-write "Oh, henlo!\n")

  ;; TODO Make sure nested msgpack values are unpacked.
  (rpc/request :nvim-win-get-cursor (msgpack.core/unpack (:data (:result (rpc/request :nvim-get-current-win))))))
