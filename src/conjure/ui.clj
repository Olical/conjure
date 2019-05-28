(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [conjure.nvim :as nvim]
            [conjure.util :as util]
            [conjure.code :as code]
            [conjure.result :as result]))

(def ^:private max-log-buffer-length 2000)
(defonce ^:private log-buffer-name "/tmp/conjure.cljc")
(def ^:private welcome-msg "; conjure/out | Welcome to Conjure!")

(defn upsert-log
  "Get, create, or update the log window and buffer."
  ([] (upsert-log {}))
  ([{:keys [focus? resize? size] :or {focus? false, resize? false, size :small}}]
   (-> (nvim/call-lua-function
         :upsert-log
         log-buffer-name
         (util/kw->snake size)
         focus?
         resize?)
       (util/snake->kw-map))))

(defn close-log
  "Closes the log window. In other news: Bear shits in woods."
  []
  (nvim/call-lua-function :close-log log-buffer-name))

(defn ^:dynamic append
  "Append the message to the log, prefixed by the origin/kind. If it's code
  then it won't prefix every line with the source, it'll place the whole string
  below the origin/kind comment. If you provide fold-text the lines will be
  wrapped with fold markers and automatically hidden with your text displayed instead."
  [{:keys [origin kind msg code? fold-text] :or {code? false}}]

  (let [prefix (str "; " (name origin) "/" (name kind))
        log (upsert-log)
        lines (util/split-lines msg)]
      (nvim/append-lines
        (merge
          log
          {:header welcome-msg
           :trim-at max-log-buffer-length
           :lines (if code?
                    (concat (when fold-text
                              [(str "; " fold-text " {{{1")])
                            [(str prefix " ⤸")]
                            lines
                            (when fold-text
                              ["; }}}1"]))
                    (for [line lines]
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
  (append {:origin (:tag conn), :kind :eval, :msg (util/sample code 50)}))

(defn result
  "Format, if it's code, and display a result from an evaluation.
  Will also fold the output if it's an error."
  [{:keys [conn resp]}]
  (let [code? (contains? #{:ret :tap} (:tag resp))]
    (append {:origin (:tag conn)
             :kind (:tag resp)
             :code? code?
             :fold-text (when (and code? (result/error? (:val resp)))
                          "Error folded")
             :msg (cond-> (:val resp)
                    (= (:tag resp) :ret) (result/value)
                    code? (util/pprint))})))

(defn load-file*
  "When we ask to load a whole file from disk."
  [{:keys [conn path]}]
  (append {:origin (:tag conn)
           :kind :load-file
           :msg path}))
