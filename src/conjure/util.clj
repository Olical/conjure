(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]
            [camel-snake-kebab.extras :as cske]))

(defn sentence [parts]
  (str/join " " parts))

(defn lines [s]
  (str/split s #"\n"))

(defn join [lines]
  (str/join "\n" lines))

(defn env [k]
  (System/getenv
    (csk/->SCREAMING_SNAKE_CASE (str "conjure-" (name k)))))

(defn error->str [error]
  (-> error Throwable->map clj/ex-triage clj/ex-str))

(defn escape-quotes [s]
  (str/escape s {\" "\\\""}))

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
         ;; stdout is redirected to stderr.
         ;; So it appears in Neovim as well as the log file.
         (println "Error from thread" (str "'" ~use-case "':") e#)
         (log/error "Error from thread" (str "'" ~use-case "':") e#)))))

(def snake->kw "some_method -> :some-method"
  (memo/lru csk/->kebab-case-keyword))

(def kw->snake ":some-method -> some_method"
  (memo/lru csk/->snake_case_string))

(def snake->kw-map
  (memo/lru #(cske/transform-keys snake->kw %)))

(def kw->snake-map
  (memo/lru #(cske/transform-keys kw->snake %)))

(defn now []
  (System/currentTimeMillis))

(defn count-str [items description]
  (let [amount (count items)
        plural? (not= amount 1)]
    (str amount " " description (when plural? "s"))))
