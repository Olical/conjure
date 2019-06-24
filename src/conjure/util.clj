(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [zprint.core :as zp]
            [camel-snake-kebab.core :as csk]
            [camel-snake-kebab.extras :as cske])
  (:import [java.net Socket]))

(defn join-words [parts]
  (str/join " " parts))

(defn join-lines [lines]
  (str/join "\n" lines))

(defn splice
  "Splice a string into another one from the starting character to the end
  character. Will cap the start and end values to keep it inside the original
  string."
  [s start end r]
  (str (subs s 0 (max 0 start))
       r
       (subs s (min (count s) end))))

(defn sample
  "Get a one line sample of some string. If the string had to be trimmed an
  ellipses will be appended onto the end."
  [code length]
  (when code
    (let [flat (str/replace code #"\s+" " ")]
      (if (> (count flat) length)
        (str (subs flat 0 length) "…")
        flat))))

(defn multiline? [s]
  (str/includes? s "\n"))

(def ^:dynamic get-env-fn #(System/getenv %))

(defn env
  "Turn :some-keyword into SOME_KEYWORD and look it up in the environment."
  [k]
  (get-env-fn
    (csk/->SCREAMING_SNAKE_CASE (name k))))

(defn throwable->str [throwable]
  (-> throwable Throwable->map clj/ex-triage clj/ex-str))

(defn escape-quotes
  "Escape backslashes and double quotes."
  [s]
  (str/escape s {\\ "\\\\"
                 \" "\\\""}))

(defn pprint
  "Format the given data, assuming it's already parsed."
  [data]
  (try
    (zp/zprint-str data)
    (catch Throwable e
      (log/error "Error while pretty printing" e)
      (pr-str data))))

(defn regexp? [o]
  (instance? java.util.regex.Pattern o))

(defn write
  "Write the full data to the stream and then flush the stream."
  [stream data]
  (doto stream
    (.write data 0 (count data))
    (.flush)))

(defmacro thread
  "Useful helper to run code in a thread but ensure errors are caught and
  logged correctly."
  [use-case & body]
  `(future
     (try
       ~@body
       (catch Throwable e#
         ;; stdout is redirected to stderr.
         ;; So it appears in Neovim as well as the log file.
         (println "Error from thread" (str "'" ~use-case "':\n") (pprint (Throwable->map e#)))
         (log/error "Error from thread" (str "'" ~use-case "':") e#)))))

(def snake->kw "some_method -> :some-method"
  (memo/lru csk/->kebab-case-keyword))

(def kw->snake ":some-method -> some_method"
  (memo/lru csk/->snake_case_string))

(def snake->kw-map
  (memo/lru #(cske/transform-keys snake->kw %)))

(def kw->snake-map
  (memo/lru #(cske/transform-keys kw->snake %)))

(defn count-str
  "Pluralises a string depending on the amount."
  [items description]
  (let [amount (count items)
        plural? (not= amount 1)]
    (str amount " " description (when plural? "s"))))

(defn free-port
  "Find a free port we can bind to."
  []
  (let [socket (java.net.ServerSocket. 0)]
    (.close socket)
    (.getLocalPort socket)))

(defn socket? [{:keys [host port]}]
  (try
    (Socket. host port)
    true
    (catch Throwable _
      false)))
