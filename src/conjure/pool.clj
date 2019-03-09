(ns conjure.pool
  "Connection management and selection."
  (:require [clojure.spec.alpha :as s]
            [clojure.core.server :as server]
            [taoensso.timbre :as log]
            [conjure.util :as util]))

(s/def ::expr util/regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::new-conn (s/keys :req-un [::tag ::port]
                          :opt-un [::expr ::lang ::host]))

(defonce conns! (atom {}))

;; Going to use server/remote-prepl for this which is sweeeet I think I need to
;; open up a remote-prepl, give it some streams, wrap those up in three
;; channels and return those in a map. We'll have aux, eval and read, just
;; like CLJS. When they nil out we attempt to remove it. On disconnect we'll
;; close eval which we can use internally to close down the remote-prepl. This
;; way if things get killed by the user or by the remote-prepl all channels
;; will close and everything will get cleaned up.

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
              :prepl (prepl/connect! {:host host, :port port})}]
    (swap! conns! assoc tag conn)

    ;; when it closes we remove it... hmm

    (a/thread
      (loop []
        (when-let [value (a/<! (get-in conn [:prepl :aux-chan]))]
          ;; display the aux
          (recur))))))

(defn conns
  ([] (vals @conns!))
  ([path]
   (->> (conns)
        (filter
          (fn [{:keys [expr]}]
            (re-find expr path)))
        (seq))))
