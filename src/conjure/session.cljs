(ns conjure.session
  "Manages active connections, can be used to look up connections to act upon."
  (:require [cljs.core.async :as a]
            [conjure.prepl :as prepl]
            [conjure.display :as display]))

;; TODO Handle failure events from prepls

(defonce conns! (atom {}))

(def default-exprs
  {:clj #"\.cljc?$"
   :cljs #"\.clj(s|c)$"})

(defn remove! [tag]
  (when-let [{:keys [prepl]} (get @conns! tag)]
    (prepl/destroy! prepl)
    (swap! conns! dissoc tag)))

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
      (when-let [result (a/<! (get-in conn [:prepl :read-chan]))]
        (display/result! result)
        (recur)))))

(defn path-conns [path]
  (filter
    (fn [{:keys [expr]}]
      (re-find expr path))
    (vals @conns!)))

(comment
  (add! {:tag :dev, :port 5555})
  (path-conns "foo.clj")
  (remove! :dev))
