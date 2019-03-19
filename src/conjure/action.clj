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

(defn- wrapped-eval [ctx {:keys [conn] :as opts}]
  (let [{:keys [eval-chan ret-chan]} (:chans conn)]
    (a/>!! eval-chan (code/eval-str ctx opts))

    ;; ClojureScript requires two evals:
    ;; * Call in-ns.
    ;; * Execute the provided code.
    ;; We throw away the in-ns result first.
    (when (= (:lang conn) :cljs)
      (a/<!! ret-chan))

    (a/<!! ret-chan)))

(defn eval* [code]
  (let [ctx (current-ctx)]
    (doseq [conn (:conns ctx)]
      (let [opts {:conn conn, :code code}]
        (ui/eval* opts)
        (ui/result {:conn conn, :resp (wrapped-eval ctx opts)})))))

(defn doc [name]
  (let [ctx (current-ctx)]
    (doseq [conn (:conns ctx)]
      (let [code (code/doc-str {:conn conn, :name name})
            result (wrapped-eval ctx {:conn conn, :code code})]
        (ui/doc {:conn conn
                 :resp (cond-> result
                         (empty? (:val result))
                         (assoc :val (str "No doc for " name)))})))))

(defn- read-range [{:keys [lines start end]}]
  (-> lines
      (update (dec (count lines)) subs 0 end)
      (update 0 subs (dec start))
      (->> (str/join "\n"))))

(defn- read-form
  "Read the current form under the cursor from the buffer by default. When
  outer? is set to true it'll read the outer most form under the cursor."
  ([] (read-form {}))
  ([{:keys [outer?]}]
   (let [forwards (str (when outer? "r") "nzW")
         backwards (str "b" forwards)

         [buf win start end]
         (nvim/call-batch
           [(nvim/get-current-buf)
            (nvim/get-current-win)
            (nvim/call-function :searchpairpos "(" "" ")" backwards)
            (nvim/call-function :searchpairpos "(" "" ")" forwards)])

         cursor (nvim/call (nvim/win-get-cursor win))
         start (if (= start [0 0]) cursor start)
         end (if (= end [0 0]) cursor end)

         lines (nvim/call
                 (nvim/buf-get-lines buf {:start (dec (first start))
                                          :end (first end)}))]

     (read-range {:lines lines
                  :start (second start)
                  :end (second end)}))))

(defn eval-inner-form []
  (eval* (read-form)))

(defn eval-outer-form []
  (eval* (read-form {:outer? true})))

(defn eval-visual-selection []
  (let [[buf [_ s-line s-col _] [_ e-line e-col]]
        (nvim/call-batch
          [(nvim/get-current-buf)
           (nvim/call-function :getpos "'<")
           (nvim/call-function :getpos "'>")])
        lines (nvim/call
                (nvim/buf-get-lines
                  buf
                  {:start (dec s-line)
                   :end e-line}))
        code (read-range {:lines lines
                          :start s-col
                          :end e-col})]
    (eval* code)))

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

  (+ 10 10)
  (time (eval* "(prn 1) (prn 2)"))
  (time (eval* "#?(:clj \"Clojure!\", :cljs \"ClojureScript!\")"))
  (time (doc "+"))
  (time (doc "nope")))
