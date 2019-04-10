(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [conjure.nvim :as nvim]
            [conjure.util :as util]
            [conjure.code :as code]))

(def ^:private log-window-widths {:small 40 :large 80})
(def ^:private max-log-buffer-length 3000)
(defonce ^:private log-buffer-name "/tmp/conjure.cljc")
(def ^:private welcome-msg "; conjure/out | Welcome to Conjure!")
(def ^:private lua
  {:upsert "return require('conjure').upsert_log(...)"
   :close "return require('conjure').close_log(...)"})

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

(defn append
  "Append the message to the log, prefixed by the origin/kind. If it's code
  then it won't prefix every line with the source, it'll place the whole string
  below the origin/kind comment."
  [{:keys [origin kind msg code?] :or {code? false}}]

  (let [prefix (str "; " (name origin) "/" (name kind))
        lines (if code?
                (into [(str prefix " ⤸")] (util/split-lines (code/pprint msg)))
                (for [line (util/split-lines msg)]
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

(defn info
  "For general information from Conjure, this is like
  a println from the system itself."
  [& parts]
  (append {:origin :conjure, :kind :out, :msg (util/join-words parts)}))

(defn error
  "For errors out of Conjure that shouldn't go to stderr."
  [& parts]
  (append {:origin :conjure, :kind :err, :msg (util/join-words parts)}))

(defn doc
  "Results from a (doc ...) call."
  [{:keys [conn resp]}]
  (append {:origin (:tag conn), :kind :doc, :msg (:val resp)}))

(defn test*
  "Results from tests."
  [{:keys [conn resp]}]
  (append {:origin (:tag conn), :kind :test, :msg (:val resp)}))

(defn eval*
  "When we send an eval and are awaiting a result, prints a short sample of the
  code we sent."
  [{:keys [conn code]}]
  (append {:origin (:tag conn), :kind :eval, :msg (code/sample code)}))

(defn result
  "Format, if it's code, and display a result from an evaluation."
  [{:keys [conn resp]}]
  (append {:origin (:tag conn)
           :kind (:tag resp)
           :code? (contains? #{:ret :tap} (:tag resp))
           :msg (:val resp)}))

(defn load-file*
  "When we ask to load a whole file from disk."
  [{:keys [conn path]}]
  (append {:origin (:tag conn)
           :kind :load-file
           :msg path}))
