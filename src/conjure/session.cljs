(ns conjure.session
  "Manages active connections, can be used to look up connections to act upon."
  (:require [clojure.spec.alpha :as s]
            [cljs.core.async :as a]
            [conjure.prepl :as prepl]
            [conjure.display :as display]))

;; TODO Handle failure events from prepls

(s/def ::expr regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::conn (s/keys :req-un [::tag ::port ::expr ::lang ::host]))
(s/def ::new-conn (s/keys :req-un [::tag ::port] :opt-un [::expr ::lang ::host]))

(defonce conns! (atom {}))

(def default-exprs
  {:clj #"\.cljc?$"
   :cljs #"\.clj(s|c)$"})

(defn remove! [tag]
  (when (display/ensure! ::tag tag)
    (when-let [{:keys [prepl]} (get @conns! tag)]
      (prepl/destroy! prepl)
      (swap! conns! dissoc tag))))

(defn add! [{:keys [tag port lang expr host]
             :or {tag :default
                  host "localhost"
                  lang :clj}}]
    (remove! tag)

    (let [conn {:tag tag
                :lang lang
                :expr (or expr (get default-exprs lang))
                :prepl (prepl/connect! {:host host, :port port})}]
      (swap! conns! assoc tag conn)

      (a/go-loop []
        (when-let [result (a/<! (get-in conn [:prepl :aux-chan]))]
          (display/aux! result)
          (recur)))))

(defn path-conns [path]
  (filter
    (fn [{:keys [expr]}]
      (re-find expr path))
    (vals @conns!)))

(defn eval! [conn code]
  (a/go
    (a/>! (get-in conn [:prepl :eval-chan]) code)
    (a/<! (get-in conn [:prepl :read-chan]))))
