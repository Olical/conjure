(ns conjure.nvim
  (:require [conjure.nvim.api :as api]
            [conjure.util :as util]))

(def ^:dynamic ctx
  "Dynamic var to be bound to some context map."
  nil)

(defn current-ctx
  "Context contains useful data that we don't watch to fetch twice while
  building code to eval. This function performs those costly calls."
  []
  (let [line-count 25
        buf (api/call (api/get-current-buf))
        get-lines (fn [end] (api/buf-get-lines buf {:start 0, :end end}))
        [path buf-length sample-lines win cwd]
        (api/call-batch
          [(api/buf-get-name buf)
           (api/buf-line-count buf)
           (get-lines line-count)
           (api/get-current-win)
           (api/call-function "getcwd" 0)])]
    (loop [sample-lines sample-lines
           line-count line-count]
      (let [ns-res (util/parse-ns (util/join-lines sample-lines))
            next-line-count (* line-count 2)]
        (if (and (= ns-res ::util/error)
                 (< line-count (min buf-length 150)))
          (recur (api/call (get-lines next-line-count)) next-line-count)
          {:path (util/resolve-relative path cwd)
           :cwd cwd
           :buf buf
           :win win
           :ns ns-res})))))

(defn- read-range
  "Given some lines, start column, and end column it will trim the first and
  last line using those columns then join the lines into once string. Useful
  for trimming api/buf-get-lines results by some sort of col/row range."
  [{:keys [lines start end]}]
  (if (empty? lines)
    ""
    (-> lines
        (update (dec (count lines))
                (fn [line]
                  (when line
                    (util/safe-subs line 0 (min end (count line))))))
        (update 0
                (fn [line]
                  (when line
                    (util/safe-subs line (max start 0)))))
        (util/join-lines))))

(defn- nil-pos?
  "A more intention revealing way of checking for [0 0] or nil positions."
  [pos]
  (or (nil? pos)
      (= pos [0 0])))

(defn read-form
  "Read the current form under the cursor from the buffer by default. When
  root? is set to true it'll read the outer most form under the cursor."
  ([] (read-form {}))
  ([{:keys [root? data-pairs? win] :or {root? false, data-pairs? true}}]
   ;; Put on your seatbelt, this function's a bit wild.
   ;; Could maybe be simplified a little but I doubt that much.

   (let [;; Used for asking Neovim for the matching character
         ;; backwards and forwards.
         forwards (str (when root? "r") "nzW")
         backwards (str "b" forwards)

         ;; searchpairpos arguments:
         ;; Ignore matches inside comments or strings.
         ;; We only have to do this for non-root form reading.
         ;;  https://github.com/Olical/conjure/issues/34
         skip (when-not root?
                "!conjure#cursor_in_code()")

         get-pair (fn [s e]
                    (let [extra-args (remove nil? [skip])]
                      [(apply api/call-function :searchpairpos s "" e backwards extra-args)
                       (apply api/call-function :searchpairpos s "" e forwards extra-args)]))

         ;; Fetch the buffer, window and all matching pairs for () [] and {}.
         ;; We'll then select the smallest region from those three
         [buf win-or-cursor cur-char & positions]
         (api/call-batch
           (concat
             [(api/get-current-buf)
              (if win
                (api/win-get-cursor win)
                (api/get-current-win))
              (api/eval* (str "matchstr(getline('.'), '\\%'.col('.').'c.')"))]
             (get-pair "(" ")")
             (when data-pairs?
               (concat
                 (get-pair "\\[" "\\]")
                 (get-pair "{" "}")))))

         ;; If the position is [0 0] we're _probably_ on the matching
         ;; character, so we should use the cursor position. Don't do this for
         ;; root though since you want to keep searching outwards.
         ;; We also avoid a second api/call if the caller provides the window for us.
         cursor (some-> (if win
                          win-or-cursor
                          (api/call (api/win-get-cursor win-or-cursor)))
                        (update 1 inc))

         get-pos (fn [pos ch]
                   (if (or (and (= cur-char ch) (nil-pos? pos))
                           (and (not root?) (= cur-char ch)))
                     cursor
                     pos))

         ;; Find all of the pairs using the fns and data above.
         pairs (keep (fn [[[start sc] [end ec]]]
                       (let [start (get-pos start sc)
                             end (get-pos end ec)]
                         (when-not (or (nil-pos? start) (nil-pos? end))
                           [start end])))
                     (->> (interleave positions (concat ["(" ")"]
                                                        (when data-pairs?
                                                          ["[" "]" "{" "}"])))
                          (partition 2) (partition 2)))

         ;; Pull the lines from the pairs we found.
         lines (api/call-batch
                 (map (fn [[start end]]
                        (api/buf-get-lines buf {:start (dec (first start))
                                                :end (first end)}))
                      pairs))

         ;; Build the potential results containing the form text, origin in the
         ;; document and local cursor position within that form.
         text (map-indexed
                (fn [n lines]
                  (let [[start end] (nth pairs n)]
                    {:form (read-range {:lines lines
                                        :start (dec (second start))
                                        :end (second end)})
                     :origin start
                     :cursor [(inc (- (first cursor)
                                      (first start)))
                              (- (second cursor)
                                 (second start))]}))
                lines)]

     ;; If we have some matches, select the largest if we want the root form
     ;; and the smallest if we want the current one.
     (when (seq text)
       ((if root? last first)
        (sort-by (comp count :form) text))))))

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
  [[file row col]]
  (api/call-batch
    [(api/command-output (str "edit " file))
     (api/win-set-cursor (:win (or ctx (current-ctx))) {:row row, :col col})]))

(defn read-selection
  "Read the current selection into a string."
  []
  (let [[buf [_ s-line s-col _] [_ e-line e-col _]]
        (api/call-batch
          [(api/get-current-buf)
           (api/call-function :getpos "'<")
           (api/call-function :getpos "'>")])
        lines (api/call
                (api/buf-get-lines
                  buf
                  {:start (dec s-line)
                   :end e-line}))]
    {:selection (read-range {:lines lines
                             :start (dec s-col)
                             :end e-col})
     :origin [s-line s-col]}))

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
               (- line-count (/ trim-at 2))
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

       (if win
         (api/win-set-cursor win {:col 0, :row new-line-count})
         (api/command "redraw!"))])
    nil))

(defn set-ready! []
  (api/call (api/set-var :conjure-ready 1)))

(defonce virtual-text-ns!
  (delay (api/call (api/create-namespace :conjure-virtual-text))))

(defn clear-virtual []
  (let [{:keys [buf]} (or ctx (current-ctx))]
    (api/call (api/buf-clear-namespace buf {:ns-id @virtual-text-ns!}))))

(defn display-virtual [chunks]
  (let [{:keys [buf win]} (or ctx (current-ctx))
        [row _] (api/call (api/win-get-cursor win))]
    (api/call-batch
      [(api/buf-clear-namespace buf {:ns-id @virtual-text-ns!})
       (api/buf-set-virtual-text buf {:ns-id @virtual-text-ns!
                                      :line (dec row)
                                      :chunks chunks})])))

(def flag
  "Read a config flag, :foo-bar will read g:conjure_foo_bar from the editor and
  cache the result. String results will get converted to keywords."
  (memoize
    (fn [k]
      (-> (api/call (api/get-var (keyword (str "conjure-" (name k)))))
          (as-> result
            (cond-> result
              (string? result) (keyword)
              (vector? result) (->> (map keyword) (set))))))))

(defn current-line
  "Get the current line number of the cursor.
  Useful in a few places where you don't want a full cursor."
  []
  (-> (api/call (api/get-current-win))
      (as-> win
        (first (api/call (api/win-get-cursor win))))))

(defn at-mark
  "Jumps the user to the specified mark, executes the function and then jumps back."
  [mark-name action]
  (let [[lazyredraw eventignore mark-pos]
        (api/call-batch
          [(api/get-option :lazyredraw)
           (api/get-option :eventignore)
           (api/call-function "getpos" (str "'" mark-name))])]
    (when (not= [0 0 0 0] mark-pos)
      (try
        (api/call-batch [(api/set-option :lazyredraw true)
                         (api/set-option :eventignore "all")
                         (api/feedkeys {:keys (str "`" mark-name)
                                        :mode :n})])
        (action)
        (finally
          (api/call-batch
            [(api/feedkeys {:keys ""
                            :mode :n})
             (api/set-option :eventignore eventignore)
             (api/set-option :lazyredraw lazyredraw)]))))))
