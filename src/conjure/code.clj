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
    (zp/zprint-str code)
    (catch Exception e
      (log/error "Error while zprinting" e)
      (if (string? code)
        code
        (pr-str code)))))

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
             (binding [*out* *err*]
               (print (-> (Throwable->map e)
                          (clojure.main/ex-triage)
                          (clojure.main/ex-str)))
               (flush)))
           (finally
             (flush)))
         ")

    :cljs
    (str "
         (in-ns '" (or ns "cljs.user") ")
         (try
           " code "
           (catch :default e
             (print (-> (cljs.repl/Error->map e)
                        (cljs.repl/ex-triage)
                        (cljs.repl/ex-str)))
             (flush))
           (finally
             (flush)))
         ")))

(defn doc-str [{:keys [conn name]}]
  (case (:lang conn)
    :clj (str "(with-out-str (clojure.repl/doc " name "))")
    :cljs (str "(with-out-str (cljs.repl/doc " name "))")))

(defn load-file-str [{:keys [conn path]}]
  (case (:lang conn)
    :clj (str "(clojure.core/load-file \"" path "\")")
    :cljs (str "(cljs.repl/load-file \"" path "\")")))
