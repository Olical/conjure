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
           (if-let [conns (seq (session/path-conns path))]
             (a/go
               (doseq [conn conns]
                 (display/result! (a/<! (session/eval! conn code)))))
             (display/error! "No matching connections."))))))

(comment
  (session/add! {:tag :dev, :port 5556, :expr #".*"})
  (eval! "(+ 10 10)")
  (eval! "(println \"henlo\")")
  (session/remove! :dev))
