(ns conjure.action
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [clojure.edn :as edn]
            [conjure.pool :as pool]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]
            [conjure.code :as code]
            [conjure.util :as util]))

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
     :ns (code/extract-ns (util/join sample-lines))
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

(defn- raw-eval [ctx {:keys [conn code]}]
  (let [{:keys [eval-chan ret-chan]} (:chans conn)]
    (a/>!! eval-chan code)
    (a/<!! ret-chan)))

(defn eval* [code]
  (when code
    (let [ctx (current-ctx)]
      (doseq [conn (:conns ctx)]
        (let [opts {:conn conn, :code code}]
          (ui/eval* opts)
          (ui/result {:conn conn, :resp (wrapped-eval ctx opts)}))))))

(defn doc [name]
  (let [ctx (current-ctx)]
    (doseq [conn (:conns ctx)]
      (let [code (code/doc-str {:conn conn, :name name})
            result (-> (wrapped-eval ctx {:conn conn, :code code})
                       (update :val edn/read-string))]
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
                (subs line 0 (min (inc end) (count line)))))
      (update 0 subs (max (dec start) 0))
      (util/join)))

(defn- nil-pos?
  "Helper function to check for [0 0] positions in a more fluent way."
  [pos]
  (= pos [0 0]))

(defn- read-form
  "Read the current form under the cursor from the buffer by default. When
  root? is set to true it'll read the outer most form under the cursor."
  ([] (read-form {}))
  ([{:keys [root?]}]
   ;; Put on your seatbelt, this function's a bit wild.
   ;; Could maybe be simplified a little but I doubt that much.

   (let [;; Used for asking Neovim for the matching character
         ;; backwards and forwards.
         forwards (str (when root? "r") "nzW")
         backwards (str "b" forwards)
         get-pair (fn [s e]
                    [(nvim/call-function :searchpairpos s "" e backwards)
                     (nvim/call-function :searchpairpos s "" e forwards)])

         ;; Fetch the buffer, window and all matching pairs for () [] and {}.
         ;; We'll then select the smallest region from those three
         [buf win cur-char & positions]
         (nvim/call-batch
           (concat
             [(nvim/get-current-buf)
              (nvim/get-current-win)
              (nvim/eval* "matchstr(getline('.'), '\\\\%'.col('.').'c.')")]
             (get-pair "(" ")")
             (get-pair "\\\\[" "\\\\]")
             (get-pair "{" "}")))

         ;; If the position is [0 0] we're _probably_ on the matching
         ;; character, so we should use the cursor position. Don't do this for
         ;; root though since you want to keep searching outwards.
         cursor (nvim/call (nvim/win-get-cursor win))
         get-pos (fn [pos ch]
                   (if (or (and (not root?) (= cur-char ch))
                           (and root? (nil-pos? pos)))
                     cursor pos))

         ;; Find all of the pairs using the fns and data above.
         pairs (keep (fn [[[start sc] [end ec]]]
                       (let [start (get-pos start sc)
                             end (get-pos end ec)]
                         (when-not (or (nil-pos? start) (nil-pos? end))
                           [start end])))
                     (->> (interleave positions ["(" ")" "[" "]" "{" "}"])
                          (partition 2) (partition 2)))

         ;; Pull the lines from the pairs we found.
         lines (nvim/call-batch
                 (map (fn [[start end]]
                        (nvim/buf-get-lines buf {:start (dec (first start))
                                                 :end (first end)}))
                      pairs))

         ;; Extract the text range (column-wise) from those groups of lines.
         text (map-indexed
                (fn [n lines]
                  (let [[start end] (nth pairs n)]
                    (read-range {:lines lines
                                 :start (second start)
                                 :end (second end)})))
                lines)]

     ;; If we have some matches, select the largest if we want the root form
     ;; and the smallest if we want the current one.
     (when (seq text)
       ((if root? last first) (sort-by count text))))))

(defn eval-current-form []
  (eval* (read-form)))

(defn eval-root-form []
  (eval* (read-form {:root? true})))

(defn eval-selection []
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

(defn eval-buffer []
  (let [code (-> (nvim/get-current-buf) (nvim/call)
                 (nvim/buf-get-lines {:start 0, :end -1}) (nvim/call)
                 (util/join))]
    (eval* code)))

(defn load-file* [path]
  (let [ctx (current-ctx)
        code (code/load-file-str path)]
    (doseq [conn (:conns ctx)]
      (let [opts {:conn conn, :code code, :path path}]
        (ui/load-file* opts)
        (ui/result {:conn conn, :resp (raw-eval ctx opts)})))))
