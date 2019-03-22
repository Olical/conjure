(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [conjure.nvim :as nvim]
            [conjure.util :as util]
            [conjure.code :as code]))

(def log-window-widths {:small 40 :large 80})
(def max-log-buffer-length 10000)
(defonce log-buffer-name (str "/tmp/conjure-log-" (util/now) ".cljc"))
(def welcome-msg ";conjure/out Welcome to Conjure!")
(def lua
  {:upsert "return conjure_utils.upsert_log(...)"
   :close "return conjure_utils.close_log(...)"})

(defn upsert-log
  "Get, create, or update the log window and buffer."
  ([] (upsert-log {}))
  ([{:keys [focus? resize? width] :or {focus? false, resize? false, width :small}}]
   (->> (nvim/execute-lua
          (:upsert lua)
          log-buffer-name
          (get log-window-widths width)
          focus?
          resize?)
        (nvim/call)
        (util/snake->kw-map))))

(defn close-log
  "Closes the log window. In other news: Bear shits in woods."
  []
  (-> (nvim/execute-lua (:close lua) log-buffer-name)
      (nvim/call))
  nil)

(defn append [{:keys [origin kind msg code?] :or {code? false}}]
  (let [prefix (str "; " (name origin) "/" (name kind))
        lines (if code?
                (into [(str prefix " ⤸")] (util/lines (code/zprint msg)))
                (for [line (util/lines msg)]
                  (str prefix " | " line)))
        {:keys [buf win]} (upsert-log)
        line-count (nvim/call (nvim/buf-line-count buf))
        trim (if (> line-count max-log-buffer-length)
               (/ max-log-buffer-length 2)
               0)
        new-line-count (+ line-count (count lines) (- trim))]

    (nvim/call-batch
      [;; Insert a welcome message on the first line when empty.
       (when (= line-count 1)
         (nvim/buf-set-lines buf {:start 0, :end 1} [welcome-msg]))

       ;; Trim the log where required.
       (when (> trim 0)
         (nvim/buf-set-lines buf {:start 0, :end trim} []))

       ;; Insert the new lines and scroll to the bottom.
       (nvim/buf-set-lines buf {:start -1, :end -1} lines)
       (nvim/win-set-cursor win {:col 0, :row new-line-count})])

    nil))

(defn info [& parts]
  (append {:origin :conjure, :kind :out, :msg (util/sentence parts)}))

(defn error [& parts]
  (append {:origin :conjure, :kind :err, :msg (util/sentence parts)}))

(defn doc [{:keys [conn resp]}]
  (append {:origin (:tag conn), :kind :doc, :msg (:val resp)}))

(defn eval* [{:keys [conn code]}]
  (append {:origin (:tag conn), :kind :eval, :msg (code/sample code)}))

(defn load-file* [{:keys [conn path]}]
  (append {:origin (:tag conn)
           :kind :load-file
           :msg path}))

(defn result [{:keys [conn resp]}]
  (append {:origin (:tag conn)
           :kind (:tag resp)
           :code? (contains? #{:ret :tap} (:tag resp))
           :msg (:val resp)}))
