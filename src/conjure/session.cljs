(ns conjure.session
  (:require [cljs.core.async :as a]
            [conjure.prepl :as prepl]
            [conjure.nvim :as nvim]))

(defonce conns! (atom {}))

(defn destroy! [{:keys [prepls]}]
  (doseq [p (vals prepls)]
    (prepl/destroy! p)))

(defn remove! [tag]
  (when-let [conn (get @conns! tag)]
    (destroy! conn)
    (swap! conns! dissoc tag)))

(defn add! [{:keys [tag host port] :or {tag :default, host "localhost"}}]
  (remove! tag)

  (let [conn {:prepls {:default (prepl/connect! {:host host, :port port})}}]
    (swap! conns! assoc tag conn)

    (a/go-loop []
      (when-let [result (a/<! (get-in conn [:prepls :default :read-chan]))]
        (nvim/echo! "result" (pr-str result))
        (recur)))

    (a/go-loop []
      (when-let [event (a/<! (get-in conn [:prepls :default :event-chan]))]
        (nvim/echo! "event" (pr-str event))
        (recur)))))

(comment
  (add! {:tag :dev, :port 5555})
  (a/go (a/>! (get-in @conns! [:dev :prepls :default :eval-chan]) "(+ 10 10)"))
  (remove! :dev))
