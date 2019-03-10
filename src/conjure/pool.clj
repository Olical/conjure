(ns conjure.pool
  "Connection management and selection."
  (:require [clojure.spec.alpha :as s]
            [clojure.core.async :as a]
            [clojure.core.server :as server]
            [clojure.java.io :as io]
            [taoensso.timbre :as log]
            [conjure.util :as util]))

(let [s (java.io.StringWriter.)]
  (.write s "foo" 0 3)
  (io/reader s))

(s/def ::expr util/regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::new-conn (s/keys :req-un [::tag ::port]
                          :opt-un [::expr ::lang ::host]))

(defonce conns! (atom {}))

(defn connect [{:keys [host port]}]
  (let [[eval-chan read-chan aux-chan] (repeatedly a/chan)]
    (server/remote-prepl host port)))

(def default-exprs
  {:clj #"\.cljc?$"
   :cljs #"\.clj(s|c)$"})

(defn remove! [tag]
  (when-let [conn (get @conns! tag)]
    (log/info "Removing:" conn)
    (swap! conns! dissoc tag)))

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
