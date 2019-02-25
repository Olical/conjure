(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]))

(defn eval! [code]
  (a/go
    (let [path (a/<! (nvim/path (nvim/buffer)))]
      (if-let [conns (seq (session/conns path))]
        (doseq [conn conns]
          (display/result! (a/<! (session/eval! conn code))))
        (display/error! "No matching connections.")))))

(comment
  (session/add! {:tag :dev, :port 5555, :expr #".*"})
  (eval! "(+ 10 10)")
  (eval! "(println \"henlo\")")
  (session/remove! :dev))
