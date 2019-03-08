(ns conjure.rpc
  (:require [clojure.core.async :as a]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]))

(defmulti handle-notify :method)

(defmethod handle-notify :default [message]
  (log/warn "Unhandled notify:" message))

(defmulti handle-request :method)

(defmethod handle-request :default [message]
  (log/warn "Unhandled request:" message))

;; TODO Remove this once other methods exist
(defmethod handle-request :ping [{:keys [params]}]
  (into ["pong"] params))

(defn handle-response [message]
  (log/error "Not handling responses yet:" message))

;; TODO Write through core.async so they don't conflict

(defn notify! [{:keys [method params] :as message}]
  (log/trace "Outgoing RPC notify:" message)
  (let [packed (msg/pack [2 method params])]
    (.write System/out packed 0 (count packed)))
  (.flush System/out))

(defn respond! [{:keys [id error result] :as message}]
  (log/trace "Outgoing RPC response:" message)
  (let [packed (msg/pack [1 id error result])]
    (.write System/out packed 0 (count packed)))
  (.flush System/out))

(def method->keyword (memo/fifo csk/->kebab-case-keyword))

(defn init! []
  (log/info "Starting RPC loop")

  (loop []
    (when-let [message (msg/unpack System/in)]
      (case (nth message 0)
        0 ;; Request and response.
        (let [id (nth message 1)
              message {:id id
                       :method (method->keyword (nth message 2))
                       :params (nth message 3)}]
          (log/trace "Incoming RPC request:" message)
          (try
            (respond! {:id id, :result (handle-request message)})
            (catch Exception error
              (respond! {:id id, :error error}))))

        1 ;; Response
        (handle-response
          {:error (nth message 2)
           :result (nth message 3)})

        2 ;; Notify
        (let [message {:method (method->keyword (nth message 1))
                       :params (nth message 2)}]
          (log/trace "Incoming RPC notify:" message)
          (handle-notify message)))

      (recur))))
