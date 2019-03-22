(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [clojure.string :as str]
            [zprint.core :as zp]
            [taoensso.timbre :as log]
            [conjure.util :as util]))

(defn zprint
  "Format the code with zprint, swallowing any errors."
  [code]
  (try
    (zp/zprint-str code {:parse-string-all? true})
    (catch Exception e
      (log/error "Error while zprinting" e)
      code)))

(defn sample
  "Get a short one line sample snippet of some code."
  [code]
  (let [flat (str/replace code #"\s+" " ")]
    (if (> (count flat) 30)
      (str (subs flat 0 30) "…")
      flat)))

(def ns-re #"\(\s*ns\s+(\D[\w\d\.\*\+!\-'?]*)\s*")
(defn extract-ns [code]
  (second (re-find ns-re code)))

(defn prelude-str [{:keys [lang]}]
  (case lang
    :clj "(require 'clojure.repl)"
    :cljs "(require 'cljs.repl)"))

;; The read-string/eval wrapper can go away with Clojure 1.11.
;; https://dev.clojure.org/jira/browse/CLJ-2453
(defn eval-str [{:keys [ns]} {:keys [conn code]}]
  (case (:lang conn)
    :clj
    (str "
         (try
           (ns " (or ns "user") ")
           (clojure.core/eval
             (clojure.core/read-string
               {:read-cond :allow}
               \"(do " (util/escape-quotes code) ")\"))
           (catch Throwable e
             (clojure.core/Throwable->map e))
           (finally
             (flush)))
         ")

    :cljs
    (str "
         (in-ns '" (or ns "cljs.user") ")
         (try
           (do " code ")
           (catch :default e
             (cljs.repl/Error->map e))
           (finally
             (flush)))
         ")))

(defn doc-str [{:keys [conn name]}]
  (case (:lang conn)
    :clj (str "(with-out-str (clojure.repl/doc " name "))")
    :cljs (str "(with-out-str (cljs.repl/doc " name "))")))

(defn load-file-str [path]
  (str "(load-file \"" path "\")"))
