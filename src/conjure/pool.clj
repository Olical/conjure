(ns conjure.pool
  "Connection management and selection."
  (:require [clojure.spec.alpha :as s]
            [clojure.core.async :as a]
            [clojure.core.server :as server]
            [clojure.java.io :as io]
            [taoensso.timbre :as log]
            [conjure.util :as util])
  (:import [java.io PipedInputStream PipedOutputStream]))

(s/def ::expr util/regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::new-conn (s/keys :req-un [::tag ::port]
                          :opt-un [::expr ::lang ::host]))

(def default-exprs
  {:clj #"\.cljc?$"
   :cljs #"\.clj(s|c)$"})

(defonce conns! (atom {}))

(defn remove! [tag]
  (when-let [conn (get @conns! tag)]
    (log/info "Removing" tag)
    (swap! conns! dissoc tag)
    (doseq [c (vals (:prepl conn))]
      (a/close! c))))

(defn connect [{:keys [tag host port]}]
  (let [[eval-chan read-chan aux-chan] (repeatedly #(a/chan 32))
        input (PipedInputStream.)
        output (PipedOutputStream. input)]

    (util/thread
      "reader loop"
      (with-open [reader (io/reader input)]
        (try
          (log/info "Connecting through remote-prepl" tag)
          (server/remote-prepl
            host port reader
            (fn [out]
              (log/trace "Read from remote-prepl" tag "-" out)
              (a/>!! (if (= (:tag out) :ret)
                       read-chan
                       aux-chan)
                     out)))

          (catch Exception e
            (log/error "Error from remote-prepl:" e))

          (finally
            (log/trace "Exited remote-prepl, cleaning up" tag)
            (remove! tag)))))

    (util/thread
      "writer loop"
      (with-open [writer (io/writer output)]
        (try
          (loop []
            (when-let [code (a/<!! eval-chan)]
              (log/trace "Writing to tag:" tag "-" code)
              (util/write writer code)
              (recur)))

          (catch Exception e
            (log/error "Error from eval-chan writing:" e))

          (finally
            (log/trace "Exited eval-chan loop, cleaning up" tag)
            (util/write writer ":repl/quit\n")))))

    {:eval-chan eval-chan
     :read-chan read-chan
     :aux-chan aux-chan}))

(defn add! [{:keys [tag lang expr]
             :or {tag :default
                  host "127.0.0.1"
                  lang :clj}
             :as new-conn}]
  (remove! tag)
  (log/info "Adding:" new-conn)

  (let [conn {:tag tag
              :lang lang
              :expr (or expr (get default-exprs lang))
              :prepl (connect new-conn)}]

    (swap! conns! assoc tag conn)

    (util/thread
      "AUX channel printer"
      (loop []
        (when-let [out (a/<!! (get-in conn [:prepl :aux-chan]))]
          ;; TODO Display the aux
          (log/trace "Aux value from" (:tag conn) "-" out)
          (recur))))))

(defn conns
  ([] (vals @conns!))
  ([path]
   (->> (conns)
        (filter
          (fn [{:keys [expr]}]
            (re-find expr path)))
        (seq))))

(comment
  (add! {:tag :test, :port 5555})
  (remove! :test)
  (a/>!! (-> (conns) first :prepl :eval-chan) "(+ 10 10)")
  (a/>!! (-> (conns) first :prepl :eval-chan) "(prn :henlo)")
  (a/<!! (-> (conns) first :prepl :read-chan)))
