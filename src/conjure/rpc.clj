(ns conjure.rpc
  (:require [clojure.core.async :as a]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]))

;; These channels handle all RPC I/O.
(defonce in-chan (a/chan 128))
(defonce out-chan (a/chan 128))

;; These functions work together to deal with
;; all incoming RPC messages from Neovim.
(defmulti handle-request :method)
(defmethod handle-request :default [msg]
  (log/warn "Unhandled request:" msg))

(defn handle-response [msg]
  (log/error "Not handling responses yet:" msg))

(defmulti handle-notify :method)
(defmethod handle-notify :default [msg]
  (log/warn "Unhandled notify:" msg))

;; TODO Remove these once other methods exist, they're for dev only
(defmethod handle-request :ping [{:keys [params]}]
  (into ["pong"] params))
(defmethod handle-notify :henlo [{:keys [params]}]
  (log/info "Henlo!" params))

(defn handle-request-response
  "Give a request to handle-request and send the results to out-chan."
  [msg]
  (a/>!! out-chan
         (merge {:type :response
                 :id (:id msg)}
                (try
                  {:result (handle-request msg)}
                  (catch Exception error
                    {:error error})))))

(def method->keyword "some_method -> :some-method"
  (memo/fifo csk/->kebab-case-keyword))
(def keyword->method ":some-method -> some_method"
  (memo/fifo csk/->snake_case_string))

(defn decode
  "Decode a msgpack vector into a descriptive map."
  [msg]
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

(defn encode
  "Encode a descriptive map into a vector ready for msgpack."
  [msg]
  (case (:type msg)
    :request  [0 (:id msg) (keyword->method (:method msg)) (:params msg)]
    :response [1 (:id msg) (:error msg) (:result msg)]
    :notify   [2 (keyword->method (:method msg)) (:params msg)]))

(defn init!
  "Start up the loops that read and write to stdin/stdout.
  This allows us to communicate with Neovim through RPC."
  []

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
          :request  (handle-request-response msg)
          :response (handle-response msg)
          :notify   (handle-notify msg))
        (recur)))))
