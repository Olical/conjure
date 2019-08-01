(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
            [clojure.core.memoize :as memo]
            [taoensso.timbre :as log]
            [zprint.core :as zp]
            [camel-snake-kebab.core :as csk]
            [camel-snake-kebab.extras :as cske])
  (:import [java.net Socket]
           [java.util.regex Pattern]))

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

(def ^:private zprint-opts
  {:style :community
   :width 120
   :map {:lift-ns? false
         :unlift-ns? true}})

(defn pprint
  "Parse and format the given string."
  [code]
  (try
    (zp/zprint-str code (merge zprint-opts {:parse-string-all? true}))
    (catch Throwable e
      (log/error "Error while pretty printing code" e)
      code)))

(defn pprint-data
  "Skip parsing, just format the given data."
  [data]
  (try
    (zp/zprint-str data zprint-opts)
    (catch Throwable e
      (log/error "Error while pretty printing data" e)
      (pr-str data))))

(defn pretty-error [{:keys [via trace phase cause]}]
  (letfn [(as-comment [s]
            (when s
              (join-lines
                (for [line (str/split-lines s)]
                  (str "; " line)))))
          (demunge [sym]
            (Compiler/demunge (name sym)))
          (format-stack-frame [[sym method file line]]
            (str (demunge sym) " (" method " " file ":" line ")"))]
    (->>
      (concat
        [(when phase
           (str "; Phase: " (name phase)))
         (when cause
           (str "; Reason...\n"
                (as-comment cause) "\n"))]
        (map-indexed
          (fn [n stack-frame]
            (str "; #" (inc n) " " (format-stack-frame stack-frame)))
          (reverse trace))
        (map-indexed
          (fn [n {:keys [message type data at]}]
            (->> (concat
                   [(str "\n; Exception #" (inc n) " " (demunge type)
                         (when at
                           (str " @ " (format-stack-frame at))))
                    (as-comment message)
                    (when data
                      (pprint-data data))])
                 (remove nil?)
                 (join-lines)))
          via))
      (remove nil?)
      (join-lines))))

(defn regexp? [o]
  (instance? Pattern o))

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
