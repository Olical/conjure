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

  ;; What are these!?
  ; {:error nil
  ;  :result [#msgpack.core.Ext{:type 0
  ;                             :data #object["[B" 0x65705a60 "[B@65705a60"]}
  ;           #msgpack.core.Ext{:type 0
  ;                             :data #object["[B" 0x13035bc "[B@13035bc"]}]}
  (rpc/request :nvim-list-bufs))
