(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [clojure.string :as str]
            [clojure.core :as core]
            [taoensso.timbre :as log]
            [conjure.util :as util]))

(defn pprint
  "Parse and format the code, suppress and log any errors."
  [code]
  (try
    (binding [*default-data-reader-fn* tagged-literal]
      (util/pprint
        (core/read-string
          {:read-cond :preserve}
          code)))
    (catch Exception e
      (log/error "Error while pretty printing" e)
      code)))

(defn sample
  "Get a short one line sample snippet of some code."
  [code]
  (let [sample-length 42]
    (let [flat (str/replace code #"\s+" " ")]
      (if (> (count flat) sample-length)
        (str (subs flat 0 sample-length) "…")
        flat))))

(defn parse-ns [code]
  (try
    (let [form (core/read-string {:read-cond :preserve} code)]
      (when (and (seq? form) (= (first form) 'ns))
        (second (filter symbol? form))))
    (catch Exception e
      (log/error "Caught error while extracting ns" e))))

(defn prelude-str [{:keys [lang]}]
  (case lang
    :clj "(do
            (require 'clojure.repl
                     'clojure.string
                     'clojure.java.io
                     'clojure.test)
            (try (require 'compliment.core) (catch Exception _)))"
    :cljs "(require 'cljs.repl 'cljs.test)"))

;; TODO Pass the line and column through from Neovim for the cursor, form or file.
;; If you're evaluating a form it needs to send the line and column for the forms first character.
;; If it's a range eval we set it to the start of the eval.
;; If it's a buffer, it's the start of the buffer.

;; TODO Replace all reader conditionals. I know the lang anyway.
(defn eval-str [{:keys [ns path line] :or {line 1}} {:keys [conn code]}]
  (let [path-args-str (when-not (str/blank? path)
                        (str " \"" path "\" \"" (last (str/split path #"/")) "\""))]
    (case (:lang conn)
      :clj
      (str "
           (try
             (ns " (or ns "user") ")
             (let [rdr (-> (java.io.StringReader. \"(do " (util/escape-quotes code) "\n)\")
                           (clojure.lang.LineNumberingPushbackReader.)
                           (doto (.setLineNumber " line ")))]
               (binding [*default-data-reader-fn* tagged-literal]
                 (. clojure.lang.Compiler (load rdr" path-args-str "))))
             (catch Throwable e
               (Throwable->map e))
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
           "))))

(defn doc-str [{:keys [conn name]}]
  (case (:lang conn)
    :clj (str "(with-out-str (clojure.repl/doc " name "))")
    :cljs (str "(with-out-str (cljs.repl/doc " name "))")))

(defn load-file-str [path]
  (str "(load-file \"" path "\")"))

(defn completions-str [{:keys [ns]} {:keys [conn prefix context]}]
  (case (:lang conn)
    :clj
    (str "
         (when-let [completions (resolve 'compliment.core/completions)]
           (completions
             \"" (util/escape-quotes prefix) "\"
             {:ns (find-ns '" (or ns "user") ")
              " (when context
                  (str ":context \"" (util/escape-quotes context) "\""))
             "}))
         ")

    ;; ClojureScript isn't supported by compliment right now.
    :cljs "[]"))

(defn definition-str [name]
  (str "
       (when-let [loc (if-let [sym (and (not (find-ns '"name")) (resolve '"name"))]
                        (mapv (meta sym) [:file :line :column])
                        (when-let [syms #?(:cljs (ns-interns '"name")
                                           :clj (some-> (find-ns '"name") ns-interns))]
                          (when-let [file (:file (meta (some-> syms first val)))]
                            [file 1 1])))]
         (when-not (or (clojure.string/blank? (first loc)) (= (first loc) \"NO_SOURCE_PATH\"))
           (-> loc
               (update
                 0
                 #?(:cljs identity
                    :clj (fn [file]
                           (if (.exists (clojure.java.io/file file))
                             file
                             (-> (clojure.java.io/resource file)
                                 (str)
                                 (clojure.string/replace #\"^file:\" \"\")
                                 (clojure.string/replace #\"^jar:file\" \"zipfile\")
                                 (clojure.string/replace #\"\\.jar!/\" \".jar::\"))))))
               (update 2 dec))))
       "))

(defn run-tests-str [targets]
  (let [targets-str (->> targets
                         (map #(str "'" %))
                         (str/join " "))]
    (str "
         (with-out-str
           #?(:clj (binding [clojure.test/*test-out* *out*]
                     (apply clojure.test/run-tests (keep find-ns #{" targets-str "})))
              :cljs (cljs.test/run-tests " targets-str ")))
         ")))

(defn run-all-tests-str [re]
  (let [re-str (when re
                 (str " #\"" (util/escape-quotes re) "\""))]
    (str "
         (with-out-str
           #?(:clj (binding [clojure.test/*test-out* *out*]
                     (clojure.test/run-all-tests" re-str "))
              :cljs (cljs.test/run-all-tests" re-str ")))
         ")))
