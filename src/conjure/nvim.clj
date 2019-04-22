(ns conjure.nvim
  (:require [conjure.nvim.api :as api]
            [conjure.code :as code]
            [conjure.util :as util]))

(defn current-ctx
  "Context contains useful data that we don't watch to fetch twice while
  building code to eval. This function performs those costly calls."
  []
  (let [buf (api/call (api/get-current-buf))
        [path sample-lines win]
        (api/call-batch
          [(api/buf-get-name buf)
           (api/buf-get-lines buf {:start 0, :end 25})
           (api/get-current-win)])]
    {:path path
     :buf buf
     :win win
     :ns (code/parse-ns (util/join-lines sample-lines))}))

(defn read-range
  "Given some lines, start column, and end column it will trim the first and
  last line using those columns then join the lines into once string. Useful
  for trimming api/buf-get-lines results by some sort of col/row range."
  [{:keys [lines start end]}]
  (-> lines
      (update (dec (count lines))
              (fn [line]
                (subs line 0 (min end (count line)))))
      (update 0 subs (max start 0))
      (util/join-lines)))

(defn nil-pos?
  "A more intention revealing way of checking for [0 0] positions."
  [pos]
  (= pos [0 0]))

(defn read-form
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
                    [(api/call-function :searchpairpos s "" e backwards)
                     (api/call-function :searchpairpos s "" e forwards)])

         ;; Fetch the buffer, window and all matching pairs for () [] and {}.
         ;; We'll then select the smallest region from those three
         [buf win cur-char & positions]
         (api/call-batch
           (concat
             [(api/get-current-buf)
              (api/get-current-win)
              (api/eval* (str "matchstr(getline('.'), '\\%'.col('.').'c.')"))]
             (get-pair "(" ")")
             (get-pair "\\[" "\\]")
             (get-pair "{" "}")))

         ;; If the position is [0 0] we're _probably_ on the matching
         ;; character, so we should use the cursor position. Don't do this for
         ;; root though since you want to keep searching outwards.
         cursor (update (api/call (api/win-get-cursor win)) 1 inc)
         get-pos (fn [pos ch]
                   (if (or (and (= cur-char ch) (nil-pos? pos))
                           (and (not root?) (= cur-char ch)))
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
         lines (api/call-batch
                 (map (fn [[start end]]
                        (api/buf-get-lines buf {:start (dec (first start))
                                                :end (first end)}))
                      pairs))

         ;; Extract the text range (column-wise) from those groups of lines.
         text (map-indexed
                (fn [n lines]
                  (let [[start end] (nth pairs n)]
                    (read-range {:lines lines
                                 :start (dec (second start))
                                 :end (second end)})))
                lines)]

     ;; If we have some matches, select the largest if we want the root form
     ;; and the smallest if we want the current one.
     (when (seq text)
       ((if root? last first) (sort-by count text))))))

(defn read-buffer
  "Read the entire current buffer into a string."
  []
  (-> (api/get-current-buf) (api/call)
      (api/buf-get-lines {:start 0, :end -1}) (api/call)
      (util/join-lines)))

(defn definition
  "Trigger built in go to definition."
  []
  (api/call (api/command-output "normal! gd")))

(defn edit-at
  "Edit the given file at the specific row and column."
  [ctx [file row col]]
  (api/call-batch
    [(api/command-output (str "edit " file))
     (api/win-set-cursor (:win ctx) {:row row, :col col})]))

(defn read-selection
  "Read the current selection into a string."
  []
  (let [[buf [_ s-line s-col _] [_ e-line e-col]]
        (api/call-batch
          [(api/get-current-buf)
           (api/call-function :getpos "'<")
           (api/call-function :getpos "'>")])
        lines (api/call
                (api/buf-get-lines
                  buf
                  {:start (dec s-line)
                   :end e-line}))]
    (read-range {:lines lines
                 :start (dec s-col)
                 :end e-col})))

(defn call-lua-function
  "Execute Conjure lua functions."
  [fn-name & args]
  (->> (apply api/execute-lua
              (str "return require('conjure')." (util/kw->snake fn-name) "(...)")
              args)
       (api/call)))

(defn append-lines [{:keys [trim-at buf win lines header]}]
  (let [line-count (api/call (api/buf-line-count buf))
        trim (if (> line-count trim-at)
               (/ trim-at 2)
               0)
        new-line-count (+ line-count (count lines) (- trim))]
    (api/call-batch
      [;; Insert a welcome message on the first line when empty.
       (when (= line-count 1)
         (api/buf-set-lines buf {:start 0, :end 1} [header]))

       ;; Trim the log where required.
       (when (> trim 0)
         (api/buf-set-lines buf {:start 0, :end trim} []))

       ;; Insert the new lines and scroll to the bottom.
       (api/buf-set-lines buf {:start -1, :end -1} lines)
       (api/win-set-cursor win {:col 0, :row new-line-count})])
    nil))
