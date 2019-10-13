(ns conjure.util
  "Anything useful and generic that's shared by multiple namespaces."
  (:require [clojure.main :as clj]
            [clojure.string :as str]
            [clojure.core.memoize :as memo]
            [clojure.tools.reader :as tr]
            [clojure.pprint :as pprint]
            [taoensso.timbre :as log]
            [me.raynes.fs :as fs]
            [camel-snake-kebab.core :as csk]
            [camel-snake-kebab.extras :as cske])
  (:import [java.net Socket]))

(defn join-words [parts]
  (str/join " " parts))

(defn join-lines [lines]
  (str/join "\n" lines))

(defn safe-subs
  "Just like subs but will cap the start
  and end based on the string length."
  ([s start]
   (subs s (max 0 start)))
  ([s start end]
   (subs s (max 0 start) (min end (count s)))))

(defn splice
  "Splice a string into another one from the starting character to the end
  character. Will cap the start and end values to keep it inside the original
  string."
  [s start end r]
  (str (safe-subs s 0 (max 0 start))
       r
       (safe-subs s (min (count s) end))))

(defn sample
  "Get a one line sample of some string. If the string had to be trimmed an
  ellipses will be appended onto the end."
  [code length]
  (when code
    (let [flat (str/replace code #"\s+" " ")]
      (if (> (count flat) length)
        (str (safe-subs flat 0 length) "…")
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

(defn parse-code
  "Parse code as data and return it, returns nil if it fails.
  Will preserve reader conditionals."
  [code]
  (try
    (binding [tr/*default-data-reader-fn* tagged-literal
              tr/*alias-map* (constantly 'user)]
      (tr/read-string {:read-cond :preserve} code))
    (catch Throwable e
      (log/warn "Failed to parse code" e))))

(defn parse-ns
  "Parse the ns symbol out of the code, return ::error if parsing failed."
  [code]
  (if-let [form (parse-code code)]
    (when (and (seq? form) (= (first form) 'ns))
      (second (filter symbol? form)))
    ::error))

(defn pprint
  "Parse and format the given string."
  [code]
  (str/trim
    (if-let [data (parse-code code)]
      (with-out-str
        (pprint/pprint data))
      code)))

(defn pprint-data
  "Skip parsing, just format the given data."
  [data]
  (try
    (str/trim
      (with-out-str
        (pprint/pprint data)))
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
         (println "Error from thread" (str "'" ~use-case "':\n") (pretty-error (Throwable->map e#)))
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

(defn path->ns
  "Demunge a path into what is probably it's namespace name."
  [path]
  (-> path
      (str/replace #"/" ".")
      (str/replace #"\.clj[cs]?$" "")
      (clj/demunge)
      (symbol)))

(defn resolve-relative
  "Successively remove parts of the path until we get to a relative path that
  points to a file we can read. If we run out of parts default to the original path."
  [original-file cwd]
  (loop [parts (cond-> (fs/split original-file)
                 (str/starts-with? original-file "/") (rest))]
    (if (seq parts)
      (let [file (apply fs/file cwd parts)]
        (if (and (fs/file? file) (fs/readable? file))
          (str/join "/" parts)
          (recur (rest parts))))
      original-file)))

(defn deep-merge
  "Recursively merges maps together. If all the maps supplied have nested maps
  under the same keys, these nested maps are merged. Otherwise the value is
  overwritten, as in `clojure.core/merge`.

  Extracted from medley for Conjure."
  {:arglists '([& maps])
   :added    "1.1.0"}
  ([] nil)
  ([a] a)
  ([a b]
   (if (and (map? a) (map? b))
     (merge-with deep-merge a b)
     b))
  ([a b & more]
   (apply merge-with deep-merge a b more)))

(defn path-in-dirs?
  "Is the given path string contained within one of the directories."
  [path dirs]
  (boolean
    (some
      (into #{} (map fs/file) dirs)
      (fs/parents path))))
