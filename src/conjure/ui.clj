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
(def ^:private max-log-buffer-length 2000)
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

;; Notes for pretty errors:
; "Constructs a data representation for a Throwable with keys:
;   :cause - root cause message
;   :phase - error phase
;   :via - cause chain, with cause keys:
;            :type - exception class symbol
;            :message - exception message
;            :data - ex-data
;            :at - top stack element
;   :trace - root cause stack elements"
;; I'll want to use clojure.lang.Compiler/demunge to parse the symbols.


(do
  (defn- pretty-error [{:keys [via cause phase trace]}]
    (letfn [(->comment [s]
              (when s
                (util/join-lines
                  (for [line (str/split-lines s)]
                    (str "; " line)))))
            (demunge [sym]
              (Compiler/demunge (name sym)))
            (stack-frame [[sym _method file line]]
              (when sym
                (str ":at " (demunge sym) " ; " file ":" line "")))]
      (->> (concat
             (map (fn [{:keys [message type data at]}]
                    (->> (concat
                           [(->comment message)
                            (str ":type " (demunge type))
                            (stack-frame at)
                            (when data
                              (util/pprint-data data))])
                         (remove nil?)
                         (util/join-lines)))
                  (reverse via))
             [(->comment cause)])
        (remove nil?)
        (str/join "\n; ===================================================================\n"))))

  (append {:origin :foo
           :kind :ret
           :code? true
           ; :fold-text "Oh no!"
           :msg (pretty-error '{:cause "ERROR: subquery must return only one column\n  Position: 176",
                                :phase :compile-syntax-check,
                                :trace
                                [[org.postgresql.core.v3.QueryExecutorImpl receiveErrorResponse
                                  "QueryExecutorImpl.java" 2440]
                                 [org.postgresql.core.v3.QueryExecutorImpl processResults
                                  "QueryExecutorImpl.java" 2183]
                                 [org.postgresql.core.v3.QueryExecutorImpl execute "QueryExecutorImpl.java"
                                  308]
                                 [org.postgresql.jdbc.PgStatement executeInternal "PgStatement.java" 441]
                                 [org.postgresql.jdbc.PgStatement execute "PgStatement.java" 365]
                                 [org.postgresql.jdbc.PgPreparedStatement executeWithFlags
                                  "PgPreparedStatement.java" 150]
                                 [org.postgresql.jdbc.PgPreparedStatement executeQuery
                                  "PgPreparedStatement.java" 113]
                                 [org.apache.commons.dbcp2.DelegatingPreparedStatement executeQuery
                                  "DelegatingPreparedStatement.java" 122]
                                 [org.apache.commons.dbcp2.DelegatingPreparedStatement executeQuery
                                  "DelegatingPreparedStatement.java" 122]
                                 [clojure.java.jdbc$execute_query_with_params invokeStatic "jdbc.clj" 1038]
                                 [clojure.java.jdbc$execute_query_with_params invoke "jdbc.clj" 1032]
                                 [clojure.java.jdbc$db_query_with_resultset_STAR_ invokeStatic "jdbc.clj"
                                  1055]
                                 [clojure.java.jdbc$db_query_with_resultset_STAR_ invoke "jdbc.clj" 1041]
                                 [clojure.java.jdbc$query invokeStatic "jdbc.clj" 1131]
                                 [clojure.java.jdbc$query invoke "jdbc.clj" 1093]
                                 [clojure.lang.AFn applyToHelper "AFn.java" 160]
                                 [clojure.lang.AFn applyTo "AFn.java" 144]
                                 [clojure.core$apply invokeStatic "core.clj" 669]
                                 [clojure.core$apply invoke "core.clj" 660]
                                 [hugsql.adapter.clojure_java_jdbc.HugsqlAdapterClojureJavaJdbc query
                                  "clojure_java_jdbc.clj" 15]
                                 [hugsql.adapter$eval15580$fn__15643$G__15562__15648 invoke "adapter.clj" 3]
                                 [hugsql.adapter$eval15580$fn__15643$G__15561__15654 invoke "adapter.clj" 3]
                                 [clojure.lang.Var invoke "Var.java" 399]
                                 [hugsql.core$db_fn_STAR_$y__15900 doInvoke "core.clj" 457]
                                 [clojure.lang.RestFn invoke "RestFn.java" 467]
                                 [social.interactions.comments$eval111098$fn__111103$fn__111106 invoke
                                  "comments.clj" 112]
                                 [social.query$with_assert_logged_in$fn__37799 invoke "query.clj" 365]
                                 [social.query$with_coerce$fn__37561 invoke "query.clj" 120]
                                 [social.interactions.comments$eval111098$fn__111103 invoke "comments.clj"
                                  64] [clojure.lang.MultiFn invoke "MultiFn.java" 239]
                                 [social.query$query_BANG_$fn__37781 invoke "query.clj" 325]
                                 [social.query$with_tx_STAR_$fn__37521 invoke "query.clj" 71]
                                 [clojure.java.jdbc$db_transaction_STAR_ invokeStatic "jdbc.clj" 771]
                                 [clojure.java.jdbc$db_transaction_STAR_ invoke "jdbc.clj" 741]
                                 [clojure.java.jdbc$db_transaction_STAR_ invokeStatic "jdbc.clj" 806]
                                 [clojure.java.jdbc$db_transaction_STAR_ invoke "jdbc.clj" 741]
                                 [clojure.java.jdbc$db_transaction_STAR_ invokeStatic "jdbc.clj" 754]
                                 [clojure.java.jdbc$db_transaction_STAR_ invoke "jdbc.clj" 741]
                                 [social.query$with_tx_STAR_ invokeStatic "query.clj" 69]
                                 [social.query$with_tx_STAR_ invoke "query.clj" 64]
                                 [social.query$query_BANG_ invokeStatic "query.clj" 324]
                                 [social.query$query_BANG_ invoke "query.clj" 321]
                                 [social.interactions.comments$eval111396 invokeStatic "comments.clj" 321]
                                 [social.interactions.comments$eval111396 invoke "comments.clj" 321]
                                 [clojure.lang.Compiler eval "Compiler.java" 7177]
                                 [clojure.lang.Compiler load "Compiler.java" 7636]
                                 [social.interactions.comments$eval111392 invokeStatic "NO_SOURCE_FILE"
                                  30908]
                                 [social.interactions.comments$eval111392 invoke "NO_SOURCE_FILE" 30898]
                                 [clojure.lang.Compiler eval "Compiler.java" 7177]
                                 [clojure.lang.Compiler eval "Compiler.java" 7167]
                                 [clojure.lang.Compiler eval "Compiler.java" 7132]
                                 [clojure.core$eval invokeStatic "core.clj" 3214]
                                 [clojure.core.server$prepl$fn__8941 invoke "server.clj" 232]
                                 [clojure.core.server$prepl invokeStatic "server.clj" 228]
                                 [clojure.core.server$prepl doInvoke "server.clj" 191]
                                 [clojure.lang.RestFn invoke "RestFn.java" 425]
                                 [clojure.core.server$io_prepl invokeStatic "server.clj" 283]
                                 [clojure.core.server$io_prepl doInvoke "server.clj" 272]
                                 [clojure.lang.RestFn invoke "RestFn.java" 397]
                                 [clojure.lang.AFn applyToHelper "AFn.java" 152]
                                 [clojure.lang.RestFn applyTo "RestFn.java" 132]
                                 [clojure.lang.Var applyTo "Var.java" 705]
                                 [clojure.core$apply invokeStatic "core.clj" 665]
                                 [clojure.core.server$accept_connection invokeStatic "server.clj" 73]
                                 [clojure.core.server$start_server$fn__8879$fn__8880$fn__8882 invoke
                                  "server.clj" 117] [clojure.lang.AFn run "AFn.java" 22]
                                 [java.lang.Thread run "Thread.java" 835]],
                                :via
                                [{:at [clojure.lang.Compiler load "Compiler.java" 7648],
                                  :data
                                  #:clojure.error{:column 1,
                                                  :line 321,
                                                  :phase :compile-syntax-check,
                                                  :source
                                                  "/home/ollie/repos/weshop/platform/src/clj/social/interactions/comments.clj"},
                                  :message
                                  "Syntax error compiling at (/home/ollie/repos/weshop/platform/src/clj/social/interactions/comments.clj:321:1).",
                                  :type clojure.lang.Compiler$CompilerException}
                                 {:at [org.postgresql.core.v3.QueryExecutorImpl receiveErrorResponse
                                       "QueryExecutorImpl.java" 2440],
                                  :message "ERROR: subquery must return only one column\n  Position: 176",
                                  :type org.postgresql.util.PSQLException}]})}))

(defn result
  "Format, if it's code, and display a result from an evaluation.
  Will also fold the output if it's an error."
  [{:keys [conn resp]}]
  (let [code? (contains? #{:ret :tap} (:tag resp))
        exception? (boolean (:exception resp))
        msg (cond-> (:val resp)
              code? (util/pprint))]

    (cond
      exception?
      (let [err-msg (-> (:val resp)
                        (code/parse-code)
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
                                   "Error folded")
                                 (when (and (= 1 (nvim/flag :fold-multiline-results))
                                            (util/multiline? msg))
                                   "Result folded")))
             :msg msg})))

(defn load-file*
  "When we ask to load a whole file from disk."
  [{:keys [conn path]}]
  (append {:origin (:tag conn)
           :kind :load-file
           :msg path}))
