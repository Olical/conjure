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
    (doseq [{:keys [chans lang] :as conn} (:conns ctx)]
      (ui/eval* {:conn conn, :code code})
      (a/>!! (:eval-chan chans) (code/eval-str (merge ctx {:conn conn
                                                           :code code})))

      ;; ClojureScript requires two evals:
      ;; * Call in-ns.
      ;; * Execute the provided code.
      ;; We throw away the in-ns result first.
      (when (= lang :cljs)
        (a/<!! (:ret-chan chans)))

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

;; TODO Fix prelude when re-adding a node conn
;; I think when I disconnect and re-connect too fast then write something node
;; shits the bed. JVM is fine with prelude. I guess I need to wait until it's
;; good to go?

;; TODO Work out why doc doesn't work with cljs.
(comment
  (pool/conns)
  (pool/add! {:tag :jvm
              :port 5555
              :lang :clj})
  (pool/add! {:tag :node
              :port 5556
              :lang :cljs
              :expr #"\.cljc?$"})
  (pool/remove-all!)

  (time (eval* "(prn 1) (prn 2)"))
  (time (eval* "#?(:clj \"Clojure!\", :cljs \"ClojureScript!\")"))
  (time (doc "+"))
  (time (doc "nope")))
