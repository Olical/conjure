(ns conjure.action
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [clojure.string :as str]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]
            [conjure.code :as code]))

;; When looking for the current ns we only ask for this many lines.
;; This avoids pulling the entire file over RPC upon every action.
(def current-ns-sample-count 25)

(defn- current-path []
  (-> (nvim/get-current-buf) (nvim/call)
      (nvim/buf-get-name) (nvim/call)))

(defn- relevant-conns []
  (let [path (current-path)]
    (if-let [conns (pool/conns path)]
      conns
      (ui/error (ui/error "No matching connections for" path)))))

(defn- current-ns []
  (let [sample (-> (nvim/get-current-buf) (nvim/call)
                   (nvim/buf-get-lines
                     {:start 0
                      :end current-ns-sample-count}) (nvim/call)
                   (->> (str/join "\n")))]
    (code/extract-ns sample)))

(defn eval* [code]
  (let [ns (current-ns)]
    (when-let [conns (relevant-conns)]
      (doseq [{:keys [chans] :as conn} conns]
        (ui/eval* {:conn conn, :code code})
        (a/>!! (:eval-chan chans) (code/eval-str {:conn conn
                                                  :ns ns
                                                  :code code}))
        (ui/result {:conn conn, :resp (a/<!! (:ret-chan chans))})))))

(defn doc [name]
  (let [ns (current-ns)]
    (when-let [conns (relevant-conns)]
      (doseq [{:keys [chans] :as conn} conns]
        (a/>!! (:eval-chan chans) (code/doc-str {:conn conn
                                                 :ns ns
                                                 :name name}))
        (let [resp (a/<!! (:ret-chan chans))]
          (ui/doc {:conn conn
                   :resp (cond-> resp
                           (empty? (:val resp))
                           (assoc :val (str "No doc for " name)))}))))))

(comment
  (pool/conns)
  (pool/add! {:port 5555})
  (time (eval* "(prn 1) (prn 2)"))
  (time (eval* "#?(:clj 1, :cljs 2)"))
  (time (doc "+"))
  (time (doc "nope")))
