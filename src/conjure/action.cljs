(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [promesa.core :as p]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]))

(defn eval! [code]
  (->> (nvim/buffer)
       (nvim/path)
       (p/map
         (fn [path]
           (doseq [conn (session/path-conns path)]
             (a/go (display/result! (a/<! (session/eval! conn code)))))))))

(comment
  ;; TODO Work out why that prn kills it.
  ;; I suspect it's a nil in a chan.
  ;; Although Clojure is fine.

  (session/add! {:tag :dev, :port 5555, :expr #".*"})
  (eval! "(+ 10 10)")
  (eval! "(prn :henlo)")
  (session/remove! :dev))
