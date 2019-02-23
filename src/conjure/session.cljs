(ns conjure.session
  (:require [conjure.prepl :as p]))

(defonce conns! (atom {}))

(defn destroy! [{:keys [prepls]}]
  (doseq [prepl (vals prepls)]
    (p/destroy! prepl)))

(defn remove! [tag]
  (when-let [conn (get tag @conns!)]
    (destroy! conn)
    (swap! conns! dissoc tag)))

(defn add! [{:keys [tag path-expr host port]}]
  (remove! tag)

  (let [conn {:tag tag
              :path-expr path-expr
              :prepls {:user (p/connect! {:host host, :port port})}}]
    (swap! conns! assoc tag conn)))
