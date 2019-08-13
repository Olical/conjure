(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [clojure.string :as str]
            [clojure.edn :as edn]
            [clojure.tools.reader :as tr]
            [taoensso.timbre :as log]
            [conjure.util :as util]
            [conjure.meta :as meta]))

(defn parse-code [code]
  (try
    (binding [tr/*default-data-reader-fn* tagged-literal
              tr/*alias-map* (constantly 'user)]
      (tr/read-string {:read-cond :preserve} code))
    (catch Throwable t
      (log/warn "Failed to parse code" t))))

(defn parse-ns
  "Parse the ns symbol out of the code, return ::error if parsing failed."
  [code]
  (if-let [form (parse-code code)]
    (when (and (seq? form) (= (first form) 'ns))
      (second (filter symbol? form)))
    ::error))

(def injected-deps!
  "Files to load, in order, to add runtime dependencies to a REPL."
  (delay (edn/read-string (slurp "target/mranderson/load-order.edn"))))

(defn prelude-strs [{:keys [lang]}]
  (case lang
    :clj (let [deps (mapv slurp @injected-deps!)
               deps-hash (hash deps)]
           (concat
             [(str "
                   (ns conjure.prelude." meta/ns-version "
                     (:require [clojure.repl]
                               [clojure.string]
                               [clojure.java.io]
                               [clojure.test]))

                   (defonce deps-hash! (atom nil))

                   (when (not= @deps-hash! " deps-hash ")
                     ")]
             deps
             [(str "
                     (reset! deps-hash! " deps-hash "))

                   :conjure/ready
                   ")]))
    :cljs [(str "
                (ns conjure.prelude." meta/ns-version "
                  (:require [cljs.repl]
                            [cljs.test]))

                :conjure/ready
                ")]))

(defn eval-str [{:keys [ns path]} {:keys [conn code line]}]
  (let [path-args-str (when-not (str/blank? path)
                        (str " \"" path "\" \"" (last (str/split path #"/")) "\""))]
    (case (:lang conn)
      :clj
      (str "
           (do
             (ns " (or ns "user") ")
             (let [rdr (-> (java.io.StringReader. \"" (util/escape-quotes code) "\n\")
                           (clojure.lang.LineNumberingPushbackReader.)
                           (doto (.setLineNumber " (or line 1) ")))]
               (binding [*default-data-reader-fn* tagged-literal]
                 (let [res (. clojure.lang.Compiler (load rdr" path-args-str "))]
                   (cond-> res (seq? res) (doall))))))
           ")

      :cljs
      (let [wrap-forms? (-> (str "[\n" code "\n]")
                            (parse-code)
                            (count)
                            (not= 1))
            code (str (when wrap-forms?
                        "(do ")
                      code "\n"
                      (when wrap-forms?
                        ")"))]
        (str "(in-ns '" (or ns "cljs.user") ")\n" code)))))

(defn doc-str [{:keys [conn name]}]
  (str "(with-out-str ("
       (case (:lang conn)
         :clj "clojure"
         :cljs "cljs")
       ".repl/doc " name "))"))

(defn load-file-str [path]
  (str "(load-file \"" path "\")"))

(defn completions-str [{:keys [ns conn prefix context]}]
  (case (:lang conn)
    :clj
    (str "
         (conjure.compliment.v0v3v8.compliment.core/completions
           \"" (util/escape-quotes prefix) "\"
           {:ns (find-ns '" (or ns "user") ")
            :extra-metadata #{:doc :arglists}
            " (when context
                (str ":context \"" (util/escape-quotes context) "\""))
           "})
         ")

    ;; ClojureScript isn't supported by Compliment yet.
    ;; https://github.com/alexander-yakushev/compliment/pull/62
    :cljs "[]"))

(defn definition-str [{:keys [name conn]}]
  (str "
       (when-let [loc (if-let [sym (and (not (find-ns '"name")) (resolve '"name"))]
                        (mapv (meta sym) [:file :line :column])
                        (when-let [syms "(case (:lang conn)
                                           :cljs (str "(ns-interns '"name")")
                                           :clj (str "(some-> (find-ns '"name") ns-interns)"))"]
                          (when-let [file (:file (meta (some-> syms first val)))]
                            [file 1 1])))]
         (when-not (or (clojure.string/blank? (first loc)) (= (first loc) \"NO_SOURCE_PATH\"))
           (-> loc
               (update
                 0
                 "
                 (case (:lang conn)
                   :cljs "identity"
                   :clj "(fn [file]
                           (if (.exists (clojure.java.io/file file))
                             file
                             (-> (clojure.java.io/resource file)
                                 (str)
                                 (clojure.string/replace #\"^file:\" \"\")
                                 (clojure.string/replace #\"^jar:file\" \"zipfile\")
                                 (clojure.string/replace #\"\\.jar!/\" \".jar::\"))))")
                 ")
               (update 2 dec))))
       "))

(defn run-tests-str [{:keys [targets conn]}]
  (let [targets-str (->> targets
                         (map #(str "'" %))
                         (str/join " "))]
    (case (:lang conn)
      :clj
      (str "
           (with-out-str
             (binding [clojure.test/*test-out* *out*]
               (apply clojure.test/run-tests (keep find-ns #{" targets-str "}))))
           ")

      :cljs
      (str "
           (with-out-str
             (cljs.test/run-tests " targets-str "))
           "))))

(defn run-all-tests-str [{:keys [re conn]}]
  (let [re-str (when re
                 (str " #\"" (util/escape-quotes re) "\""))]

    (case (:lang conn)
      :clj
      (str "
           (with-out-str
             (binding [clojure.test/*test-out* *out*]
               (clojure.test/run-all-tests" re-str ")))
           ")

      :cljs
      (str "
           (with-out-str
             (cljs.test/run-all-tests" re-str "))
           "))))
