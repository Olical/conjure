(ns conjure.actions
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]))

(defn evaluate [code]
  (let [path (-> (nvim/get-current-buf) (nvim/call)
                 (nvim/buf-get-name) (nvim/call))]
    (if-let [conns (seq (pool/conns path))]
      (doseq [{:keys [prepl] :as conn} conns]
        (a/>!! (:eval-chan prepl) code)
        (ui/result {:conn conn, :resp (a/<!! (:read-chan prepl))}))
      (ui/error (str "No matching connections for: " path)))))

(comment
  (pool/conns)
  (pool/add! {:port 5555})
  (time (evaluate "(prn 1) (prn 2)")))
