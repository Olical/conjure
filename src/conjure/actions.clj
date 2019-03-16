(ns conjure.actions
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]
            [conjure.code :as code]))

(defn- current-path []
  (-> (nvim/get-current-buf) (nvim/call)
      (nvim/buf-get-name) (nvim/call)))

(defn- relevant-conns []
  (let [path (current-path)]
    (if-let [conns (pool/conns path)]
      conns
      (ui/error (ui/error "No matching connections for" path)))))

(defn user-eval [code]
  (when-let [conns (relevant-conns)]
    (doseq [{:keys [chans] :as conn} conns]
      (a/>!! (:eval-chan chans) code)
      (ui/result {:conn conn, :resp (a/<!! (:ret-chan chans))}))))

(defn user-doc [name]
  (when-let [{:keys [chans] :as conn} (first (relevant-conns))]
    (a/>!! (:eval-chan chans) (code/doc-str name))
    (let [resp (a/<!! (:ret-chan chans))]
      (ui/doc {:conn conn
               :resp (cond-> resp
                       (empty? (:val resp))
                       (assoc :val (str "No doc for " name)))}))))

(comment
  (pool/conns)
  (pool/add! {:port 5555})
  (time (user-eval "(prn 1) (prn 2)"))
  (time (user-doc "+"))
  (time (user-doc "nope")))
