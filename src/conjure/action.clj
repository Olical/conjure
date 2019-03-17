(ns conjure.action
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [clojure.string :as str]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]
            [conjure.code :as code]))

(defn- current-ctx
  "Context contains useful data that we don't watch to fetch twice while
  building code to eval. This function performs those costly calls."
  []
  (let [buf (-> (nvim/get-current-buf) (nvim/call))
        [path sample-lines]
        (nvim/call-batch
          [(nvim/buf-get-name buf)
           (nvim/buf-get-lines buf {:start 0, :end 25})])
        conns (pool/conns path)]
    {:path path
     :ns (code/extract-ns (str/join "\n" sample-lines))
     :conns (or conns (ui/error "No matching connections for" path))}))

(defn eval* [code]
  (let [ctx (current-ctx)]
    (doseq [{:keys [chans] :as conn} (:conns ctx)]
      (ui/eval* {:conn conn, :code code})
      (a/>!! (:eval-chan chans) (code/eval-str (merge ctx {:conn conn
                                                           :code code})))
      (ui/result {:conn conn, :resp (a/<!! (:ret-chan chans))}))))

(defn doc [name]
  (let [ctx (current-ctx)]
    (doseq [{:keys [chans] :as conn} (:conns ctx)]
      (a/>!! (:eval-chan chans) (code/doc-str (merge ctx {:conn conn
                                                          :name name})))
      (let [resp (a/<!! (:ret-chan chans))]
        (ui/doc {:conn conn
                 :resp (cond-> resp
                         (empty? (:val resp))
                         (assoc :val (str "No doc for " name)))})))))

(comment
  (pool/conns)
  (pool/add! {:tag :dev-jvm
              :port 5555
              :lang :clj})
  (pool/add! {:tag :dev-node
              :port 5556
              :lang :cljs
              :expr #"\.cljc?$"})
  (time (eval* "(prn 1) (prn 2)"))
  (time (eval* "#?(:clj 1, :cljs 2)"))
  (time (doc "+"))
  (time (doc "nope")))
