(ns conjure.code
  "Tools to render code for evaluation. The response from these functions
  should be sent to an environment for evaluation."
  (:require [clojure.string :as str]
            [backtick :as bt]
            [clojure.edn :as edn]
            [clojure.template :as tmpl]
            [conjure.util :as util]
            [conjure.meta :as meta]))

(def ^:private injected-deps!
  "Files to load, in order, to add runtime dependencies to a REPL."
  (delay (edn/read-string (slurp "target/mranderson/load-order.edn"))))

(def ^:private deps-ns
  "Namespace to store injected dependency related information under."
  (symbol (str "conjure.deps." meta/ns-version)))

(defmulti render
  "Render the template strings with opts."
  (fn [name _opts]
    name))

(defmacro ^:private deftemplate
  "Small helper to define templates with.
  See conjure.code/render multimethod."
  [name params & body]
  `(defmethod render ~name [_name# opts#]
     (let [~params [opts#]]
       ~@body)))

(def ^:private ^:dynamic *pprint-tmpl?* true)

(defmacro ^:private let-tmpl
  "Build a template with let bindings, returns a pprinted string.
  Does not support destructuring since it uses clojure.template.
  Only the top most let-tmpl will be pprinted, any sub-templates in the value
  side of the bindings will be returned as data."
  [bindings & exprs]
  (let [argv (vec (take-nth 2 bindings))
        values (vec (take-nth 2 (rest bindings)))]
    `(cond-> (apply tmpl/apply-template
                    '~argv
                    '~(if (= (count exprs) 1)
                        (first exprs)
                        `(do ~@exprs))
                    (binding [*pprint-tmpl?* false]
                      ~values)
                    nil)
       *pprint-tmpl?* (util/pprint-data))))

(defmacro tmpl
  "Render code templates like syntax quoting in macros.
  Returns a pprinted string, sub-calls to tmpl will return data for composition."
  [& exprs]
  `(cond-> (binding [*pprint-tmpl?* false]
             (bt/template
               ~(if (= (count exprs) 1)
                  (first exprs)
                  `(do ~@exprs))))
     *pprint-tmpl?* (util/pprint-data)))

(defn- wrap-clojure-eval
  "Ensure the code is evaluated with reader conditionals and an optional
  line number of file path."
  [{:keys [path code line]}]
  (let [path-args (when-not (str/blank? path)
                    [path (last (str/split path #"/"))])]
    (tmpl
      (let [rdr (-> (java.io.StringReader. ~code)
                    (clojure.lang.LineNumberingPushbackReader.)
                    (doto (.setLineNumber ~(or line 1))))]
        (binding [*default-data-reader-fn* tagged-literal]
          (let [res (. clojure.lang.Compiler (load rdr ~@path-args))]
            (cond-> res (seq? res) (doall))))))))

;; Used in templates because my linter freaks out otherwise.
(def ^:private ns-sym 'ns)
(def ^:private require-kw :require)

(deftemplate :deps-hash [_opts]
  (tmpl
    (~ns-sym ~deps-ns)
    (defonce deps-hash! (atom nil))
    @deps-hash!))

(deftemplate :deps [{:keys [lang current-deps-hash]}]
  (case lang
    :clj (let [injected-deps @injected-deps!
               deps-hash (hash injected-deps)]
           (concat
             [(tmpl
                (~ns-sym
                  ~deps-ns
                  (~require-kw [clojure.repl]
                               [clojure.string]
                               [clojure.java.io]
                               [clojure.test])))
              (tmpl
                (reset! deps-hash! ~deps-hash))]
             (when (not= current-deps-hash deps-hash)
               (map #(wrap-clojure-eval {:code (slurp %)
                                         :path %})
                    injected-deps))))
    :cljs [(tmpl
             (~ns-sym
               ~deps-ns
               (~require-kw [cljs.repl]
                            [cljs.test])))]))

(deftemplate :eval [{:keys [conn code line]
                     {:keys [ns path]} :ctx}]
  (case (:lang conn)
    :clj
    (tmpl
      (~ns-sym ~(or ns 'user))
      ~(wrap-clojure-eval {:code code
                           :path path
                           :line line}))
    :cljs
    ;; TODO Support ~@ splicing.
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

(deftemplate :load-file [{:keys [path]}]
  (let-tmpl [-path path]
    (load-file -path)))

(deftemplate :completions [{:keys [ns conn prefix context]}]
  (case (:lang conn)
    :clj
    (let-tmpl [-prefix prefix
               -context context
               -ns (or ns 'user)]
      (conjure.compliment.v0v3v9.compliment.core/completions
        -prefix
        (merge
          {:ns (find-ns '-ns)
           :extra-metadata #{:doc :arglists}}
          (when-let [context -context]
            {:context context}))))

    ;; ClojureScript isn't supported by Compliment yet.
    ;; https://github.com/alexander-yakushev/compliment/pull/62
    :cljs (let-tmpl []
            [])))

;; TODO Swap to Orchard when 0.5 is released.
#_(defn info-str
    "Get the information map for a given namespace and symbol."
    [{:keys [conn name]}]
    (case (:lang conn)
      :clj (str "(conjure.orchard.v0v5v0-beta11.orchard.info/info (symbol (str *ns*)) '" name ")")
      :cljs "{}"))

;; TODO Replace with Orchard.
(deftemplate :doc [{:keys [conn name]}]
  (let-tmpl [-doc-sym (case (:lang conn)
                        :clj 'clojure.repl/doc
                        :cljs 'cljs.repl/doc)
             -name (symbol name)]
    (with-out-str
      (-doc-sym -name))))

;; TODO Replace with Orchard
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

(deftemplate :run-tests [{:keys [targets conn]}]
  (case (:lang conn)
    :clj
    (let-tmpl [-targets targets]
      (with-out-str
        (binding [clojure.test/*test-out* *out*]
          (apply clojure.test/run-tests (keep find-ns '-targets)))))
    :cljs
    ;; TODO Support ~@ splicing.
    (str "(with-out-str (cljs.test/run-tests "
         (str/join " " (map #(str "'" %) targets))
         "))")))

(deftemplate :run-all-tests [{:keys [re conn]}]
  (let [args (when re
               [(re-pattern re)])]
    (case (:lang conn)
      :clj
      (let-tmpl [-run (concat '(clojure.test/run-all-tests) args)]
        (with-out-str
          (binding [clojure.test/*test-out* *out*]
            -run)))

      :cljs
      (let-tmpl [-run (concat '(cljs.test/run-all-tests) args)]
        (with-out-str
          -run)))))

(deftemplate :refresh [{:keys [conn op]
                        {:keys [before after dirs]} :config}]
  (when (= (:lang conn) :clj)
    (let-tmpl [-ns 'conjure.toolsnamespace.v0v3v1.clojure.tools.namespace.repl
               -before before
               -after after
               -dirs dirs
               -op (case op
                     :clear 'clear
                     :changed 'refresh
                     :all 'refresh-all)]
      (let [repl-ns '-ns
            before '-before
            after '-after
            op '-op
            dirs -dirs]
        (when before
          (require (symbol (namespace before)))
          ((resolve before)))
        (when dirs
          (apply (ns-resolve repl-ns 'set-refresh-dirs) dirs))
        (apply (ns-resolve repl-ns op)
               (when (and (not= op 'clear) after)
                 [:after after]))))))
