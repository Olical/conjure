(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [conjure.session :as session]
            [conjure.nvim :as nvim]
            [conjure.display :as display]))

(defn eval! [code]
  (a/go
    (let [buffer (a/<! (nvim/buffer))
          path (a/<! (nvim/path buffer))]
      (if-let [conns (session/conns path)]
        (doseq [conn conns]
          (display/result! conn (a/<! (session/eval! conn code))))
        (display/error! "No matching connections for path:" path)))))

(comment
  (session/add! {:tag :dev, :port 5555, :expr #".*"})
  (eval! "(+ 10 10)")
  (eval! "(println \"henlo\")")
  (session/remove! :dev))
