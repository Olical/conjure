(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.edn :as edn]
            [clojure.spec.alpha :as s]
            [clojure.string :as str]
            [expound.alpha :as expound]
            [taoensso.timbre :as log]
            [camel-snake-kebab.core :as csk]))

(defn sentence [parts]
  (str/join " " parts))

(defn error [& parts]
  (let [msg (sentence parts)]
    (doseq [line (str/split msg #"\n")]
      (log/error line))
    (binding [*out* *err*]
      (println msg))))

(defn parse-user-edn [spec src]
  (let [value (edn/read-string src)]
    (if (s/valid? spec value)
      value
      (error (expound/expound-str spec value)))))

(defn env
  ([spec k]
   (some->> (env k) (parse-user-edn spec)))

  ([k]
   (System/getenv
     (csk/->SCREAMING_SNAKE_CASE (str "conjure-" (name k))))))

(defn error->str [error]
  (-> error Throwable->map clj/ex-triage clj/ex-str))

(defn regexp? [o]
  (instance? java.util.regex.Pattern o))
