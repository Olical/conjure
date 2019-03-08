(ns conjure.rpc
  (:require [clojure.core.async :as a]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]))

(defonce in-chan (a/chan 128))
(defonce out-chan (a/chan 128))

(defmulti handle-notify :method)

(defmethod handle-notify :default [msg]
  (log/warn "Unhandled notify:" msg))

(defmulti handle-request :method)

(defmethod handle-request :default [msg]
  (log/warn "Unhandled request:" msg))

;; TODO Remove this once other methods exist
(defmethod handle-request :ping [{:keys [params]}]
  (into ["pong"] params))

(defn handle-response [msg]
  (log/error "Not handling responses yet:" msg))

(def method->keyword (memo/fifo csk/->kebab-case-keyword))
(def keyword->method (memo/fifo csk/->snake_case_string))

(defn decode [msg]
  (case (nth msg 0)
    0 {:type :request
       :id (nth msg 1)
       :method (method->keyword (nth msg 2))
       :params (nth msg 3)}
    1 {:type :response
       :id (nth msg 1)
       :error (nth msg 2)
       :result (nth msg 3)}
    2 {:type :notify
       :method (method->keyword (nth msg 1))
       :params (nth msg 2)}))

(defn encode [msg]
  (case (:type msg)
    :request  [0 (:id msg) (keyword->method (:method msg)) (:params msg)]
    :response [1 (:id msg) (:error msg) (:result msg)]
    :notify   [2 (keyword->method (:method msg)) (:params msg)]))

(defn send-response! [{:keys [id]} response]
  (a/>!! out-chan (merge {:type :response, :id id} response)))

(defn init! []
  ;; Prevent anyone writing to *out* since that's for msgpack-rpc.
  (alter-var-root #'*out* (constantly *err*))

  (log/info "Starting RPC loops")

  ;; Read from stdin and place messages on in-chan.
  (a/thread
    (loop []
      (when-let [msg (msg/unpack System/in)]
        (log/trace "RPC message received:" msg)
        (let [decoded (decode msg)]
          (log/trace "Decoded to this:" decoded)
          (a/>!! in-chan decoded))
        (recur))))

  ;; Read from out-chan and place messages in stdout.
  (a/thread
    (loop []
      (when-let [msg (a/<!! out-chan)]
        (log/trace "Sending RPC message:" msg)
        (let [encoded (encode msg)
              packed (msg/pack encoded)]
          (log/trace "Encoded as this:" encoded)
          (.write System/out packed 0 (count packed))
          (.flush System/out)
          (log/trace "Sent!"))
        (recur))))

  ;; Read messages from in-chan, handle them, put results onto out-chan where required.
  (a/thread
    (loop []
      (when-let [msg (a/<!! in-chan)]
        (case (:type msg)
          :request (try
                     (send-response! msg {:result (handle-request msg)})
                     (catch Exception error
                       (send-response! msg {:error error})))
          :response (handle-response msg)
          :notify (let [msg {:method (method->keyword (nth msg 1))
                             :params (nth msg 2)}]
                    (handle-notify msg)))
        (recur)))))
