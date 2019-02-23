(ns conjure.prepl
  (:require [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [cljs.reader :as reader]
            [applied-science.js-interop :as j]))

(defonce net (node/require "net"))

(defn destroy! [{:keys [socket read eval events]}]
  (j/call socket :destroy)

  (doseq [c [read eval events]]
    (a/close! c)))

(defn connect! [{:keys [host port]}]
  (let [socket (j/call net :connect #js {"host" host, "port" port})
        [read eval events] (repeatedly a/chan)]

    (doto socket
      (j/call :setEncoding "utf8")

      (j/call :on "close"
              (fn [error?]
                (a/go
                  (a/>! events {:type :close
                                :error? error?}))))

      (j/call :on "error"
              (fn [error]
                (a/go
                  (a/>! events {:type :error
                                :error error}))))

      (j/call :on "drain"
              (fn []
                (a/go
                  (a/>! events {:type :drain}))))

      (j/call :on "end"
              (fn []
                (a/go
                  (a/>! events {:type :end}))))

      (j/call :on "ready"
              (fn []
                (a/go
                  (a/>! events {:type :ready}))))

      (j/call :on "timeout"
              (fn []
                (a/go
                  (a/>! events {:type :timeout}))))

      (j/call :on "connect"
              (fn []
                (a/go
                  (a/>! events {:type :connect}))))

      (j/call :on "lookup"
              (fn [error address family host]
                (a/go
                  (a/>! events {:type :end
                                :error error
                                :address address
                                :family family
                                :host host}))))

      (j/call :on "data"
              (fn [body]
                (a/go
                  (a/>! read (reader/read-string body))
                  (a/>! events {:type :data
                                :body body})))))

    (a/go-loop []
      (when-let [code (a/<! eval)]
        (j/call socket :write code)
        (recur)))

    {:socket socket
     :read read
     :eval eval
     :events events}))
