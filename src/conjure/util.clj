(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
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
