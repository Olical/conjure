(ns conjure.action
  "Actions a user can perform."
  (:require [cljs.core.async :as a]
            [promesa.core :as p]
            [conjure.session :as session]
            [conjure.nvim :as nvim]))

(defn eval! [code]
  (->> (nvim/buffer)
       (nvim/path)
       (p/map
         (fn [path]
           (a/go
             (doseq [conn (session/path-conns path)]
               (a/>! (get-in conn [:prepl :eval-chan]) code)))))))

;; TODO Pipe evals to another channel to enable eval -> ret mapping.
;; This way I don't need many prepl connections to do different things!
;; So the eval! function should eval, capture the ret and then display it.
;; All out, err and tap go to the log by default, eval is the only one that gets piped.

(comment
  (session/add! {:tag :dev, :port 5556, :expr #".*"})
  (eval! "(+ 10 10)")
  (session/remove! :dev))
