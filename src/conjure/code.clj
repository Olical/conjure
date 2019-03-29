(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [clojure.string :as str]
            [clojure.core :as core]
            [fipp.clojure :as fipp]
            [taoensso.timbre :as log]
            [conjure.util :as util]))

(def ^:private read-opts {:read-cond :preserve})
(defn pprint
  "Parse and format the code, suppress and log any errors."
  [code]
  (try
    (with-out-str
      (fipp/pprint (core/read-string read-opts code)))
    (catch Exception e
      (log/error "Error while pretty printing" e)
      code)))

(def ^:private sample-length 42)
(defn sample
  "Get a short one line sample snippet of some code."
  [code]
  (let [flat (str/replace code #"\s+" " ")]
    (if (> (count flat) sample-length)
      (str (subs flat 0 sample-length) "…")
      flat)))

(def ^:private ns-re #"\(\s*ns\s+(\D[\w\d\.\*\+!\-'?]*)\s*")
(defn extract-ns [code]
  (second (re-find ns-re code)))

(defn prelude-str [{:keys [lang]}]
  (case lang
    :clj "(require 'clojure.repl 'compliment.core)"
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
               \"(do " (util/escape-quotes code) "\n)\"))
           (catch Throwable e
             (clojure.core/Throwable->map e))
           (finally
             (flush)))
         ")

    :cljs
    (str "
         (in-ns '" (or ns "cljs.user") ")
         (try
           " code "
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

(defn completions-str [{:keys [ns]} {:keys [conn prefix]}]
  (case (:lang conn)
    :clj
    (str "
         (when (find-ns 'compliment.core)
           (compliment.core/completions
             \"" (util/escape-quotes prefix) "\"
             {:ns (find-ns '" ns ")}))
         ")

    ;; ClojureScript isn't supported by compliment right now.
    :cljs "[]"))
