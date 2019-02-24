(ns conjure.prepl
  "Wrapper around a raw prepl connection, simply provides some basic parsing of responses and talking to node's net module."
  (:require [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [cljs.reader :as reader]
            [applied-science.js-interop :as j]))

(defonce net (node/require "net"))

(defn destroy! [{:keys [socket read-chan eval-chan event-chan]}]
  (j/call socket :destroy)

  (doseq [c [read-chan eval-chan event-chan]]
    (a/close! c)))

(defn connect! [{:keys [host port]}]
  (let [socket (j/call net :connect #js {"host" host, "port" port})
        [read-chan eval-chan event-chan] (repeatedly a/chan)]

    (doto socket
      (j/call :setEncoding "utf8")

      (j/call :on "close"
              (fn [error?]
                (a/go
                  (a/>! event-chan {:type :close
                                    :error? error?}))))

      (j/call :on "error"
              (fn [error]
                (a/go
                  (a/>! event-chan {:type :error
                                    :error error}))))

      (j/call :on "drain"
              (fn []
                (a/go
                  (a/>! event-chan {:type :drain}))))

      (j/call :on "end"
              (fn []
                (a/go
                  (a/>! event-chan {:type :end}))))

      (j/call :on "ready"
              (fn []
                (a/go
                  (a/>! event-chan {:type :ready}))))

      (j/call :on "timeout"
              (fn []
                (a/go
                  (a/>! event-chan {:type :timeout}))))

      (j/call :on "connect"
              (fn []
                (a/go
                  (a/>! event-chan {:type :connect}))))

      (j/call :on "lookup"
              (fn [error address family host]
                (a/go
                  (a/>! event-chan {:type :end
                                    :error error
                                    :address address
                                    :family family
                                    :host host}))))

      (j/call :on "data"
              (fn [body]
                (a/go
                  (a/>! read-chan (reader/read-string body))
                  (a/>! event-chan {:type :data
                                    :body body})))))

    (a/go-loop []
      (when-let [code (a/<! eval-chan)]
        (j/call socket :write code)
        (recur)))

    {:socket socket
     :read-chan read-chan
     :eval-chan eval-chan
     :event-chan event-chan}))
