(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [conjure.nvim :as nvim]
            [conjure.util :as util]
            [conjure.code :as code]))

(def ^:private log-window-widths {:small 40 :large 80})
(def ^:private max-log-buffer-length 3000)
(defonce ^:private log-buffer-name "/tmp/conjure.cljc")
(def ^:private welcome-msg "; conjure/out | Welcome to Conjure!")

(defn upsert-log
  "Get, create, or update the log window and buffer."
  ([] (upsert-log {}))
  ([{:keys [focus? resize? width] :or {focus? false, resize? false, width :small}}]
   (-> (nvim/call-lua-function
         :upsert-log
         log-buffer-name
         (get log-window-widths width)
         focus?
         resize?)
       (util/snake->kw-map))))

(defn close-log
  "Closes the log window. In other news: Bear shits in woods."
  []
  (nvim/call-lua-function :close-log log-buffer-name))

(defn append
  "Append the message to the log, prefixed by the origin/kind. If it's code
  then it won't prefix every line with the source, it'll place the whole string
  below the origin/kind comment."
  [{:keys [origin kind msg code?] :or {code? false}}]

  (let [prefix (str "; " (name origin) "/" (name kind))]
    (nvim/append-lines
      (merge
        (upsert-log)
        {:header welcome-msg
         :trim-at max-log-buffer-length
         :lines (if code?
                  (into [(str prefix " ⤸")] (util/split-lines (code/pprint msg)))
                  (for [line (util/split-lines msg)]
                    (str prefix " | " line)))}))))

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
  (append {:origin (:tag conn)
           :kind :test
           :msg (if (string? (:val resp))
                  (:val resp)
                  (pr-str (:val resp)))}))

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
