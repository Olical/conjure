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
           (a/go
             (doseq [conn (session/path-conns path)]
               (a/>! (get-in conn [:prepl :eval-chan]) code)
               (display/result! (a/<! (get-in conn [:prepl :read-chan])))))))))

(comment
  (session/add! {:tag :dev, :port 5556, :expr #".*"})
  (eval! "(+ 10 10)")
  (eval! "(prn :henlo)")
  (session/remove! :dev))
