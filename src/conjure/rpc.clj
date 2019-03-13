(ns conjure.rpc
  "Bi-directional communication with Neovim through msgpack-rpc."
  (:require [clojure.core.async :as a]
            [taoensso.timbre :as log]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]
            [conjure.util :as util]))

;; These channels handle all RPC I/O.
(defonce in-chan (a/chan 128))
(defonce out-chan (a/chan 128))

;; Used to keep track of which requests are in flight.
(defonce open-requests! (atom {}))

;; These three functions work together to deal
;; with all incoming RPC messages from Neovim.
(defmulti handle-request :method)
(defmethod handle-request :default [msg]
  (log/warn "Unhandled request:" msg))

(defn- handle-response
  "Deliver the error or result to any existing request."
  [{:keys [id error result] :as response}]
  (log/trace "Received response:" response)
  (swap! open-requests!
         (fn [requests]
           (when-let [reqp (get requests id)]
             (deliver reqp {:error error, :result result})
             (dissoc requests id)))))

(defmulti handle-notify :method)
(defmethod handle-notify :default [msg]
  (log/warn "Unhandled notify:" msg))

(defn- handle-request-response
  "Give a request to handle-request and send the results to out-chan."
  [msg]
  (a/>!!  out-chan
         (merge {:type :response
                 :id (:id msg)}
                (try
                  {:result (handle-request msg)}
                  (catch Exception error
                    {:error (util/error->str error)})))))

(defn- decode
  "Decode a msgpack vector into a descriptive map."
  [msg]
  (case (nth msg 0)
    0 {:type :request
       :id (nth msg 1)
       :method (util/snake->kw (nth msg 2))
       :params (vec (nth msg 3))}
    1 {:type :response
       :id (nth msg 1)
       :error (nth msg 2)
       :result (nth msg 3)}
    2 {:type :notify
       :method (util/snake->kw (nth msg 1))
       :params (vec (nth msg 2))}))

(defn- encode
  "Encode a descriptive map into a vector ready for msgpack."
  [{:keys [type id method params error result]}]
  (case type
    :request  [0 id (util/kw->snake method) (vec params)]
    :response [1 id error result]
    :notify   [2 (util/kw->snake method) (vec params)]))

(defn- request-id
  "The lowest available request ID starting at 1."
  [requests]
  (some
    (fn [n]
      (when-not (contains? requests n)
        n))
    (rest (range))))

(defn request
  "Send a request and block until we get a response.
  Split out into a future if you need to!"
  [{:keys [method params]}]
  (let [id! (atom nil)
        reqp (promise)]
    (swap! open-requests!
           (fn [requests]
             (let [id (request-id requests)]
               (reset! id! id)
               (assoc requests id reqp))))

    (let [request {:type :request
                   :id @id!
                   :method method
                   :params params}]
      (a/>!! out-chan request)
      (log/trace "Sent request, awaiting response:" request))

    @reqp))

(defn init
  "Start up the loops that read and write to stdin/stdout.
  This allows us to communicate with Neovim through RPC."
  []

  ;; Prevent anyone writing to *out* since that's for msgpack-rpc.
  (alter-var-root #'*out* (constantly *err*))

  (log/info "Starting RPC loops")

  ;; Read from stdin and place messages on in-chan.
  (util/thread
    "RPC stdin handler"
    (loop []
      (when-let [msg (try
                       (msg/unpack System/in)
                       (catch Exception e
                         (log/error "Error while unpacking from stdin:" e)))]
        (try
          (log/trace "RPC message received:" msg)
          (let [decoded (decode msg)]
            (log/trace "Decoded to this:" decoded)
            (a/>!! in-chan decoded))
          (catch Exception e
            (log/error "Error while reading from stdin:" e)))
        (recur))))

  ;; Read from out-chan and place messages in stdout.
  (util/thread
    "RPC stdout"
    (loop []
      (when-let [msg (a/<!! out-chan)]
        (try
          (log/trace "Sending RPC message:" msg)
          (let [encoded (encode msg)
                packed (msg/pack encoded)]
            (log/trace "Encoded as this:" encoded)
            (util/write System/out packed)
            (log/trace "Sent!"))
          (catch Exception e
            (log/error "Error while writing to stdout:" e)))
        (recur))))

  ;; Handle all messages on in-chan through the handler-* functions.
  (loop []
    (when-let [msg (a/<!! in-chan)]
      (util/thread
        "RPC message handler"
        (case (:type msg)
          :request  (handle-request-response msg)
          :response (handle-response msg)
          :notify   (handle-notify msg)))
      (recur))))
