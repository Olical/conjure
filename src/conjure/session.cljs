(ns conjure.session
  "Manages active connections, can be used to look up connections to act upon."
  (:require [clojure.spec.alpha :as s]
            [cljs.core.async :as a]
            [conjure.prepl :as prepl]
            [conjure.display :as display]))

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
  (when-let [{:keys [prepl]} (get @conns! tag)]
    (prepl/destroy! prepl)
    (swap! conns! dissoc tag)
    (display/message! (str "[" (name tag) "]") "Removed.")))

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
        (display/aux! conn result)
        (recur)))

    (a/go-loop []
      (when-let [event (a/<! (get-in conn [:prepl :event-chan]))]
        (case (:type event)
          (:close :error :end :timeout)
          (do
            (remove! tag)
            (display/error! (str "[" (name tag) "]") "Closed:" event))

          :ready (display/message! (str "[" (name tag) "]") "Connected!")

          nil)
        (recur)))))

(defn conns
  ([] (vals @conns!))
  ([path]
   (->> (conns)
        (filter
          (fn [{:keys [expr]}]
            (re-find expr path)))
        (seq))))

(defn eval! [conn code]
  (a/go
    (a/>! (get-in conn [:prepl :eval-chan]) code)
    (a/<! (get-in conn [:prepl :read-chan]))))
