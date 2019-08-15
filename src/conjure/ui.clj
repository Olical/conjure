(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [clojure.string :as str]
            [clojure.main :as main]
            [conjure.nvim :as nvim]
            [conjure.util :as util]
            [conjure.code :as code]
            [conjure.meta :as meta])
  (:import [clojure.lang Compiler]))

(def ^:private welcome-msg (str "; conjure/out | Welcome to Conjure! (" meta/version ")"))
(def ^:private max-log-buffer-length 1000)
(defonce ^:private log-buffer-name "/tmp/conjure.cljc")

(defn upsert-log
  "Get, create, or update the log window and buffer."
  ([] (upsert-log {}))
  ([{:keys [focus? resize? open? size]
     :or {focus? false, resize? false, open? true, size :small}}]
   (-> (nvim/call-lua-function
         :upsert-log
         log-buffer-name
         (util/kw->snake size)
         focus?
         resize?
         open?)
       (util/snake->kw-map))))

(defn log-open?
  "Check if the log window is currently open."
  []
  (boolean (:win (upsert-log {:open? false}))))

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

  ;; Ensure we have the essentials before attempting to append.
  ;; Kind can be nil if the evaluation failed completely, like if the server is gone.
  (when (and origin kind msg)
    (let [prefix (str "; " (name origin) "/" (name kind))
          log (upsert-log {:open? (not
                                    (contains?
                                      (nvim/flag :log-blacklist)
                                      (if (and (= kind :ret) (util/multiline? msg))
                                        :ret-multiline
                                        kind)))})
          lines (str/split-lines msg)]
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
                      (str prefix " | " line)))})))))

(defn error
  "For errors out of Conjure that shouldn't go to stderr."
  [& parts]
  (append {:origin :conjure, :kind :err, :msg (util/join-words parts)}))

(defn up
  "Output from the up command."
  [& parts]
  (append {:origin :conjure, :kind :up, :msg (util/join-words parts)}))

(defn status
  "Output from the status command."
  [& parts]
  (append {:origin :conjure, :kind :status, :msg (util/join-words parts)}))

(defn doc
  "Results from a (doc ...) call."
  [{:keys [conn resp]}]
  (append {:origin (:tag conn), :kind :doc, :msg (:val resp)}))

(defn quick-doc
  "Display inline documentation."
  [s]
  (when (string? s)
    (nvim/display-virtual
      [[(str "?> "
             (-> (str/split s #"\n" 2)
                 (last)
                 (util/sample 256)))
        "comment"]])))

(defn up-summary
  "Display which connections have been made by ConjureUp inline."
  [tags]
  (nvim/display-virtual
    [[(str "@> "
           (if (empty? tags)
             "No connections"
             (str "Connected to " (str/join ", " tags))))
      "comment"]]))

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
  (let [sample (util/sample code 256)]
    (nvim/display-virtual
      [[(str "#> " sample) "comment"]])

    (append {:origin (:tag conn)
             :kind :eval
             :msg sample})))

(defn result
  "Format, if it's code, and display a result from an evaluation.
  Will also fold the output if it's an error."
  [{:keys [conn resp]}]
  (let [code? (contains? #{:ret :tap} (:tag resp))
        exception? (boolean (:exception resp))
        msg (cond
              exception? (util/pretty-error
                           (util/parse-code (:val resp)))
              code? (util/pprint (:val resp))
              :else (:val resp))]

    (cond
      exception?
      (let [err-msg (-> (:val resp)
                        (util/parse-code)
                        (main/ex-triage)
                        (main/ex-str))]
        (nvim/display-virtual
          [[(str "!> " (util/sample err-msg 256)) "comment"]])

        (append {:origin (:tag conn)
                 :kind :err
                 :msg err-msg}))

      (= :ret (:tag resp))
      (nvim/display-virtual
        [[(str "=> " (util/sample msg 256)) "comment"]]))

    (append {:origin (:tag conn)
             :kind (:tag resp)
             :code? code?
             :fold-text (and code?
                             (or (when exception?
                                   "Full error folded")
                                 (when (and (= 1 (nvim/flag :fold-multiline-results))
                                            (util/multiline? msg))
                                   "Full result folded")))
             :msg msg})))

(defn load-file*
  "When we ask to load a whole file from disk."
  [{:keys [conn path]}]
  (append {:origin (:tag conn)
           :kind :load-file
           :msg path}))

(defn refresh
  "When namespaces are being refreshed."
  [{:keys [conn flags]}]
  (append {:origin (:tag conn)
           :kind :refresh
           :msg (str "Refreshing"
                     (when (seq flags)
                       (str " " (str/join ", " flags))))}))
