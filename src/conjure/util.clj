(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]))

(defn sentence [parts]
  (str/join " " parts))

(defn lines [s]
  (str/split s #"\n"))

(defn env [k]
  (System/getenv
    (csk/->SCREAMING_SNAKE_CASE (str "conjure-" (name k)))))

(defn error->str [error]
  (-> error Throwable->map clj/ex-triage clj/ex-str))

(defn regexp? [o]
  (instance? java.util.regex.Pattern o))

(defn write [stream data]
  (doto stream
    (.write data 0 (count data))
    (.flush)))

(defmacro thread [use-case & body]
  `(future
     (try
       ~@body
       (catch Exception e#
         (log/error "Error from thread" (str "'" ~use-case "':") e#)))))

(def snake->kw "some_method -> :some-method"
  (memo/fifo csk/->kebab-case-keyword))

(def kw->snake ":some-method -> some_method"
  (memo/fifo csk/->snake_case_string))
