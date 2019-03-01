(ns conjure.prepl
  "Wrapper around a raw prepl connection, simply provides some basic parsing of responses and talking to node's net module."
  (:require [cljs.nodejs :as node]
            [cljs.reader :as reader]
            [applied-science.js-interop :as j]
            [cljs.core.async :as a]
            [conjure.async :as async :include-macros true]
            [conjure.code :as code]))

(defonce net (node/require "net"))

(defn destroy! [{:keys [socket eval-chan read-chan aux-chan event-chan]}]
  (j/call socket :destroy)

  (doseq [c [eval-chan read-chan aux-chan event-chan]]
    (a/close! c)))

(defn connect! [{:keys [host port]}]
  (let [socket (j/call net :connect #js {"host" host, "port" port})
        [eval-chan read-chan aux-chan event-chan] (repeatedly a/chan)]

    (doto socket
      (j/call :setEncoding "utf8")

      (j/call :on "close"
              (fn [error?]
                (async/go
                  (a/>! event-chan {:type :close
                                    :error? error?}))))

      (j/call :on "error"
              (fn [error]
                (async/go
                  (a/>! event-chan {:type :error
                                    :error error}))))

      (j/call :on "drain"
              (fn []
                (async/go
                  (a/>! event-chan {:type :drain}))))

      (j/call :on "end"
              (fn []
                (async/go
                  (a/>! event-chan {:type :end}))))

      (j/call :on "ready"
              (fn []
                (async/go
                  (a/>! event-chan {:type :ready}))))

      (j/call :on "timeout"
              (fn []
                (async/go
                  (a/>! event-chan {:type :timeout}))))

      (j/call :on "connect"
              (fn []
                (async/go
                  (a/>! event-chan {:type :connect}))))

      (j/call :on "lookup"
              (fn [error address family host]
                (async/go
                  (a/>! event-chan {:type :lookup
                                    :error error
                                    :address address
                                    :family family
                                    :host host}))))

      (j/call :on "data"
              (fn [body]
                (async/go
                  (let [{:keys [tag] :as raw-res} (reader/read-string body)
                        res (cond-> raw-res (contains? #{:out :tap} tag) (update :val code/pretty-print))]
                    (if (= (:tag res) :ret)
                      (a/>! read-chan res)
                      (a/>! aux-chan res)))
                  (a/>! event-chan {:type :data
                                    :body body})))))

    (a/go-loop []
      (when-let [code (a/<! eval-chan)]
        (async/catch! (j/call socket :write (str code "\n")))
        (recur)))

    {:socket socket
     :eval-chan eval-chan
     :read-chan read-chan
     :aux-chan aux-chan
     :event-chan event-chan}))
