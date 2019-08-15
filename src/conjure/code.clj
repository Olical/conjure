(ns conjure.code
  "Tools to render code for evaluation. The response from these functions
  should be sent to an environment for evaluation."
  (:require [clojure.string :as str]
            [clojure.edn :as edn]
            [conjure.util :as util]
            [conjure.meta :as meta]))

(def injected-deps!
  "Files to load, in order, to add runtime dependencies to a REPL."
  (delay (edn/read-string (slurp "target/mranderson/load-order.edn"))))

(def ^:private deps-ns
  "Namespace to store injected dependency related information under."
  (str "conjure.deps." meta/ns-version))

(defn deps-hash-str
  "Upserts the deps-hash atom and namespace then fetches the current value."
  []
  (str "(do
          (ns " deps-ns ")
          (defonce deps-hash! (atom nil))
          @deps-hash!)\n"))

(defn- wrap-clojure-eval
  "Ensure the code is evaluated with reader conditionals and an optional
  line number of file path."
  [{:keys [path code line]}]
  (let [path-args-str (when-not (str/blank? path)
                        (str " \"" path "\" \"" (last (str/split path #"/")) "\""))]
    (str "
         (let [rdr (-> (java.io.StringReader. \"" (util/escape-quotes code) "\n\")
                       (clojure.lang.LineNumberingPushbackReader.)
                       (doto (.setLineNumber " (or line 1) ")))]
           (binding [*default-data-reader-fn* tagged-literal]
             (let [res (. clojure.lang.Compiler (load rdr" path-args-str "))]
               (cond-> res (seq? res) (doall)))))
         ")))

(defn deps-strs
  "Sequence of forms to evaluate to ensure that all dependencies are loaded.
  Requires current-deps-hash to work out if there's any work to do or not."
  [{:keys [lang current-deps-hash]}]
  (case lang
    :clj (let [injected-deps @injected-deps!
               deps-hash (hash injected-deps)]
           (concat
             [(str "(ns " deps-ns "
                      (:require [clojure.repl]
                                [clojure.string]
                                [clojure.java.io]
                                [clojure.test]))\n")
              (str "(reset! deps-hash! " deps-hash ")\n")]
             (when (not= current-deps-hash deps-hash)
               (map #(wrap-clojure-eval {:code (slurp %)
                                         :path %})
                    injected-deps))))
    :cljs [(str "(ns " deps-ns "
                   (:require [cljs.repl]
                             [cljs.test]))\n")]))

(defn eval-str
  "Prepare code for evaluation."
  [{:keys [ns path]} {:keys [conn code line]}]
  (case (:lang conn)
    :clj
    (str "
         (do
           (ns " (or ns "user") ")
           " (wrap-clojure-eval {:code code
                                 :path path
                                 :line line}) ")\n")

    :cljs
    (let [wrap-forms? (-> (str "[\n" code "\n]")
                          (util/parse-code)
                          (count)
                          (not= 1))
          code (str (when wrap-forms?
                      "(do ")
                    code "\n"
                    (when wrap-forms?
                      ")"))]
      (str "(in-ns '" (or ns "cljs.user") ")\n" code))))

(defn load-file-str
  "Loads a file, won't work on remote environments."
  [path]
  (str "(load-file \"" path "\")"))

(defn completions-str
  "Find completions for a prefix and context string."
  [{:keys [ns conn prefix context]}]
  (case (:lang conn)
    :clj
    (str "(conjure.compliment.v0v3v9.compliment.core/completions
            \"" (util/escape-quotes prefix) "\"
            {:ns (find-ns '" (or ns "user") ")
             :extra-metadata #{:doc :arglists}
             " (when context
                 (str ":context \"" (util/escape-quotes context) "\""))
            "})\n")

    ;; ClojureScript isn't supported by Compliment yet.
    ;; https://github.com/alexander-yakushev/compliment/pull/62
    :cljs "[]"))

;; TODO Swap to Orchard when 0.5 is released.
#_(defn info-str
    "Get the information map for a given namespace and symbol."
    [{:keys [conn name]}]
    (case (:lang conn)
      :clj (str "(conjure.orchard.v0v5v0-beta11.orchard.info/info (symbol (str *ns*)) '" name ")")
      :cljs "{}"))

(defn doc-str
  "Lookup documentation and capture the *out* into a string."
  [{:keys [conn name]}]
  (str "(with-out-str ("
       (case (:lang conn)
         :clj "clojure"
         :cljs "cljs")
       ".repl/doc " name "))"))

(defn definition-str
  "Find where a given symbol is defined, returns [file line column]."
  [{:keys [name conn]}]
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

(defn run-tests-str
  "Executes tests in the given namespaces."
  [{:keys [targets conn]}]
  (let [targets-str (->> targets
                         (map #(str "'" %))
                         (str/join " "))]
    (case (:lang conn)
      :clj
      (str "(with-out-str
              (binding [clojure.test/*test-out* *out*]
                (apply clojure.test/run-tests (keep find-ns #{" targets-str "}))))\n")

      :cljs
      (str "(with-out-str
              (cljs.test/run-tests " targets-str "))\n"))))

(defn run-all-tests-str
  "Executes all tests with an optional namespace filter regular expression."
  [{:keys [re conn]}]
  (let [re-str (when re
                 (str " #\"" (util/escape-quotes re) "\""))]

    (case (:lang conn)
      :clj
      (str "(with-out-str
              (binding [clojure.test/*test-out* *out*]
                (clojure.test/run-all-tests" re-str ")))\n")

      :cljs
      (str "(with-out-str
              (cljs.test/run-all-tests" re-str "))\n"))))

(defn refresh-str
  "Refresh changed namespaces."
  [{:keys [conn op config]
    {:keys [before after dirs]} :config}]
  (when (= (:lang conn) :clj)
    (let [prefix "conjure.toolsnamespace.v0v3v1.clojure.tools.namespace.repl"]
      (str (when before
             (str "(require '" (namespace before) ") "
                  "(" before ") "))
           (when dirs
             (str "(apply " prefix "/set-refresh-dirs " (pr-str dirs) ") "))
           "(" prefix "/"
           (case op
             :clear "clear"
             :changed "refresh"
             :all "refresh-all")
           (when (and (not= op :clear) after)
             (str " :after '" after))
           ")"))))
