(ns conjure.prepl
  (:require [cljs.nodejs :as node]
            [cljs.core.async :as a]
            [cljs.reader :as reader]
            [applied-science.js-interop :as j]))

(defonce net (node/require "net"))
(defonce conn-id! (atom 0))
(defonce conns! (atom []))

(defn conns []
  @conns!)

(defn destroy! [id]
  (let [{:keys [socket read eval events] :as conn}
        (first (filter #(= id (:id %)) (conns)))]

    (when conn
      (swap! conns!
             (fn [conns]
               (filterv #(not= % conn) conns)))

      (j/call socket :destroy)

      (doseq [c [read eval events]]
        (a/close! c))

      nil)))

(defn connect! [opts]
  (let [id (swap! conn-id! inc)
        socket (j/call net :connect (clj->js (select-keys opts #{:host :port})))
        [read eval events] (repeatedly a/chan)
        conn (merge
               (select-keys opts #{:name :expression :language})
               {:id id
                :socket socket
                :read read
                :eval eval
                :events events})]

    (swap! conns! conj conn)

    (doto socket
      (j/call :on "close"
              (fn [error?]
                (a/go
                  (a/>! events {:type :close
                                :error? error?})
                  (destroy! id))))

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
                  (a/>! read (reader/read-string (j/call body :toString)))
                  (a/>! events {:type :data
                                :body body})))))

    (a/go-loop []
      (when-let [code (a/<! eval)]
        (j/call socket :write code)
        (recur)))

    conn))

(comment
  (count (conns))

  (doseq [id (map :id (conns))]
    (destroy! id))

  (do
    (def conn (connect!
                {:name "test"
                 :expression #"clj(s|c)$"
                 :language :cljs
                 :host "localhost"
                 :port 5885}))

    (a/go-loop []
      (when-let [res (<! (:read conn))]
        (prn "=== res" res)
        (recur)))

    (a/go-loop []
      (when-let [event (<! (:events conn))]
        (prn "=== event" event)
        (recur))))

  (a/go (a/>! (:eval conn) "(+ 10 10)\n")))
