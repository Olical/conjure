(ns conjure.rpc
  "Communication with Neovim through msgpack RPC and other plugins via JSON RPC."
  (:require [clojure.core.async :as a]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [msgpack.core :as msg]
            [msgpack.clojure-extensions]
            [net.tcp.server :as tcp]
            [jsonista.core :as json]
            [conjure.util :as util])
  (:import (com.fasterxml.jackson.core JsonParser$Feature)))

;; TCP port that the RPC opens up on for other plugins to use.
(defonce port (util/free-port))

;; Used to read and write JSON values.
;; Need to do some weird Java stuff to prevent the JSON parser closing the socket.
(def json-mapper
  (doto (json/object-mapper)
    (-> (.getFactory) (.disable JsonParser$Feature/AUTO_CLOSE_SOURCE))))

;; These channels handle all RPC I/O.
(defonce ^:private in-chan (a/chan 128))
(defonce ^:private out-chan (a/chan 128))

;; Used to keep track of which requests are in flight.
(defonce ^:private open-requests! (atom {}))

;; These three functions work together to deal
;; with all incoming RPC messages from Neovim.
(defmulti handle-request :method)
(defmethod handle-request :default [msg]
  (log/warn "Unhandled request:" msg))

(defn- handle-response
  "Deliver the error or result to any existing request."
  [{:keys [id error result]}]
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
  (a/>!! out-chan
         (merge {:type :response}
                (select-keys msg #{:id :client})
                (try
                  {:result (handle-request msg)}
                  (catch Throwable error
                    {:error (util/throwable->str error)})))))

(defn- decode*
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

;; Pack can be entirely cached because we give it concrete
;; data as arguments. The unpacking takes a stream so we
;; can only cache the ouput of that stream function.

(def decode
  "Decode an already unpacked payload under an LRU cache."
  (memo/lru
    (fn [data]
      (try
        (decode* data)
        (catch Throwable e
          (log/error "Error while decoding" e))))))

(def pack
  "Encode then pack the payload under an LRU cache."
  (memo/lru
    (fn [{:keys [data transport]}]
      (try
        (let [payload (encode data)]
          (case transport
            :msgpack (msg/pack payload)
            :json (str (json/write-value-as-string payload json-mapper) "\n")))
        (catch Throwable e
          (log/error "Error while packing" e))))))

(defn- request-id
  "The lowest available request ID starting at 1."
  [requests]
  (some
    (fn [n]
      (when-not (contains? requests n)
        n))
    (rest (range))))

(defn ^:dynamic request
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
                   :client :stdio
                   :id @id!
                   :method method
                   :params params}]
      (a/>!! out-chan request))

    @reqp))

(defn init
  "Start up the loops that read and write to stdin/stdout.
  This allows us to communicate with Neovim through RPC.
  There is also a TCP server started on {conjure.rpc/port} that
  allows other plugins to communicate with Conjure over JSON RPC."
  []

  ;; Prevent anyone writing to *out* since that's for msgpack-rpc.
  (alter-var-root #'*out* (constantly *err*))

  ;; This server allows other plugins to make RPC calls over a JSON TCP socket.
  (log/info "Starting RPC TCP server on port" port)
  (-> (tcp/tcp-server
        :port port
        :handler (tcp/wrap-io
                   (fn [reader writer]
                     (log/info "TCP connection opened")

                     (loop []
                       (when-let [msg (some-> (json/read-value reader json-mapper) (decode))]
                         (try
                           (a/>!! in-chan (assoc msg :client writer))
                           (catch Throwable e
                             (log/error "Error while writing to in-chan:" e)))
                         (recur)))

                     (log/info "TCP connection closing"))))
      (tcp/start))

  (log/info "Starting RPC loops")

  ;; Read from stdin and place messages on in-chan.
  (util/thread
    "RPC stdin handler"
    (loop []
      (when-let [msg (decode (msg/unpack System/in))]
        (try
          (a/>!! in-chan (assoc msg :client :stdio))
          (catch Throwable e
            (log/error "Error while writing to in-chan:" e)))
        (recur))))

  ;; Read from out-chan and send messages to the client.
  (util/thread
    "RPC stdout"
    (loop []
      (when-let [msg (a/<!! out-chan)]
        (try
          (log/trace "Sending RPC message:" msg)
          (if (= (:client msg) :stdio)
            (util/write System/out (pack {:data msg, :transport :msgpack}))
            (util/write (:client msg) (pack {:data msg, :transport :json})))
          (catch Throwable e
            (log/error "Error while writing to client:" (:client msg) e)))
        (recur))))

  ;; Handle all messages on in-chan through the handler-* functions.
  (util/thread
    "RPC event loop"
    (loop []
      (when-let [msg (a/<!! in-chan)]
        (log/trace "Received RPC message:" msg)
        (util/thread
          "RPC message handler"
          (case (:type msg)
            :request  (handle-request-response msg)
            :response (handle-response msg)
            :notify   (handle-notify msg)))
        (recur)))))
