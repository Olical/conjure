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
    (log/info "Removing:" conn)
    (swap! conns! dissoc tag)
    (doseq [c (vals (:prepl conn))]
      (a/close! c))))

;; TODO Ensure the prepl thread is killed (future?) when removed
;; TODO Ensure we remove everything else if the prepl dies
(defn connect [{:keys [tag host port]}]
  (let [[eval-chan read-chan aux-chan] (repeatedly a/chan)
        input (PipedInputStream.)
        output (PipedOutputStream. input)]

    (a/thread
      (with-open [in-reader (io/reader output)]
        (server/remote-prepl host port in-reader
                             (fn [{:keys [tag] :as out}]
                               (a/>!! (if (= tag :eval) read-chan aux-chan) out))))
      (remove! tag))

    (a/thread
      (loop []
        (when-let [code (a/<!! eval-chan)]
          (.write input code 0 (count code))
          (recur))))

    {:eval-chan eval-chan
     :read-chan read-chan
     :aux-chan aux-chan}))

(defn add! [{:keys [tag port lang expr host]
             :or {tag :default
                  host "localhost"
                  lang :clj}
             :as new-conn}]

  (log/info "Adding:" new-conn)
  (remove! tag)

  (let [conn {:tag tag
              :lang lang
              :expr (or expr (get default-exprs lang))
              :prepl (connect {:host host, :port port})}]

    (swap! conns! assoc tag conn)

    ;; when it closes we remove it... hmm

    (a/thread
      (loop []
        (when-let [value (a/<! (get-in conn [:prepl :aux-chan]))]
          ;; TODO Display the aux
          (log/trace "Aux value from:" conn "-" value)
          (recur))))))

(defn conns
  ([] (vals @conns!))
  ([path]
   (->> (conns)
        (filter
          (fn [{:keys [expr]}]
            (re-find expr path)))
        (seq))))
