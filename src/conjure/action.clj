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
     :buf buf
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

(defn- read-range
  "Given some lines, start column, and end column it will trim the first and
  last line using those columns then join the lines into once string. Useful
  for trimming nvim/buf-get-lines results by some sort of col/row range."
  [{:keys [lines start end]}]
  (-> lines
      (update (dec (count lines))
              (fn [line]
                (subs line 0 (min end (count line)))))
      (update 0 subs (max (dec start) 0))
      (->> (str/join "\n"))))

;; TODO Read the form even when on the first paren.
;; It reads the previous form if there is one I think... or the parent...
;; TODO Treat {} and [] as forms too.
(defn- read-form
  "Read the current form under the cursor from the buffer by default. When
  root? is set to true it'll read the outer most form under the cursor."
  ([] (read-form {}))
  ([{:keys [root?]}]
   (let [forwards (str (when root? "r") "nzW")
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

(defn eval-current-form []
  (eval* (read-form)))

(defn eval-root-form []
  (eval* (read-form {:root? true})))
