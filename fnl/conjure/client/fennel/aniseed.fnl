(module conjure.client.fennel.aniseed
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string
             view conjure.aniseed.view
             client conjure.client
             mapping conjure.mapping
             fs conjure.fs
             text conjure.text
             log conjure.log
             config conjure.config
             extract conjure.extract}})

(def buf-suffix ".fnl")
(def context-pattern "%(%s*module%s+(.-)[%s){]")
(def comment-prefix "; ")

(config.merge
  {:client
   {:fennel
    {:aniseed
     {:mapping {:run_buf_tests "tt"
                :run_all_tests "ta"}
      :aniseed_module_prefix :conjure.aniseed.
      :use_metadata true}}}})

(def- cfg (config.get-in-fn [:client :fennel :aniseed]))

(def- ani-aliases
  {:nu :nvim.util})

(defn- ani [mod-name f-name]
  (let [mod-name (a.get ani-aliases mod-name mod-name)
        mod (require (.. (cfg [:aniseed_module_prefix]) mod-name))]
    (if f-name
      (a.get mod f-name)
      mod)))

(defn- anic [mod f-name ...]
  ((ani mod f-name) ...))

(defonce- repls {})

(def default-module-name "conjure.user")

(defn module-name [context file-path]
  (if
    context context
    file-path (or (fs.file-path->module-name file-path) default-module-name)
    default-module-name))

(defn repl [opts]
  (let [filename (a.get opts :filename)]
    (or (and (not (a.get opts :fresh?)) (a.get repls filename))
        (let [repl (anic :eval :repl opts)]
          (repl (.. "(module " (a.get opts :moduleName) ")"))
          (tset repls filename repl)
          repl))))

(defn display-result [opts]
  (when opts
    (let [{: ok? : results} opts
          result-str (if ok?
                       (if (a.empty? results)
                         "nil"
                         (str.join "\n" (a.map view.serialise results)))
                       (a.first results))
          result-lines (str.split result-str "\n")]
      (when (not opts.passive?)
        (log.append
          (if ok?
            result-lines
            (a.map #(.. "; " $1) result-lines))))
      (when opts.on-result-raw
        (opts.on-result-raw results))
      (when opts.on-result
        (opts.on-result result-str)))))

(defn eval-str [opts]
  ((client.wrap
     (fn []
       (let [out (anic :nu :with-out-str
                       (fn []
                         (when (and (cfg [:use_metadata])
                                    (not package.loaded.fennel))
                           (set package.loaded.fennel (anic :fennel :impl)))

                         (let [eval! (repl {:filename opts.file-path
                                            :moduleName (module-name opts.context opts.file-path)
                                            :useMetadata (cfg [:use_metadata])
                                            :onError (fn [err-type err lua-source]
                                                       (set opts.ok? false)
                                                       (set opts.results [err]))})
                               results (eval! opts.code)]
                           (when (not= false opts.ok?)
                             (set opts.ok? true)
                             (set opts.results results)))))]
         (when (not (a.empty? out))
           (log.append (text.prefixed-lines (text.trim-last-newline out) "; (out) ")))
         (display-result opts))))))

(defn doc-str [opts]
  (a.assoc opts :code (.. "(doc " opts.code ")"))
  (eval-str opts))

(defn eval-file [opts]
  (set opts.code (a.slurp opts.file-path))
  (when opts.code
    (eval-str opts)))

(defn- wrapped-test [req-lines f]
  (log.append req-lines {:break? true})
  (let [res (anic :nu :with-out-str f)]
    (log.append
      (-> (if (= "" res)
            "No results."
            res)
          (text.prefixed-lines "; ")))))

(defn run-buf-tests []
  (let [c (extract.context)]
    (when c
      (wrapped-test
        [(.. "; run-buf-tests (" c ")")]
        #(anic :test :run c)))))

(defn run-all-tests []
  (wrapped-test ["; run-all-tests"] (ani :test :run-all)))

(defn on-filetype []
  (mapping.buf :n :FnlRunBufTests
               (cfg [:mapping :run_buf_tests]) *module-name* :run-buf-tests)
  (mapping.buf :n :FnlRunAllTests
               (cfg [:mapping :run_all_tests]) *module-name* :run-all-tests))

(defn value->completions [x]
  (when (= :table (type x))
    (->> (if (. x :aniseed/autoload-enabled?)
           (do
             (. x :trick-aniseed-into-loading-the-module)
             (. x :aniseed/autoload-module))
           x)
         (a.kv-pairs)
         (a.filter
           (fn [[k v]]
             (not (text.starts-with k "aniseed/"))))
         (a.map
           (fn [[k v]]
             {:word k
              :kind (type v)
              :menu nil
              :info nil})))))

(defn completions [opts]
  (let [code (when (not (str.blank? opts.prefix))
               (.. "((. (require :" *module-name* ") :value->completions) "
                   (string.gsub opts.prefix "%..*$" "")
                   ")"))
        mods (value->completions package.loaded)
        locals (let [(ok? m) (and opts.context (pcall #(require opts.context)))]
                 (if ok?
                   (a.concat
                     (value->completions m)
                     (value->completions (a.get m :aniseed/locals))
                     mods)
                   mods))
        result-fn
        (fn [results]
          (let [xs (a.first results)]
            (opts.cb
              (if (= :table (type xs))
                (a.concat
                  (a.map
                    (fn [x]
                      (a.update x :word #(.. opts.prefix $1)))
                    xs)
                  locals)
                locals))))
        (ok? err-or-res)
        (when code
          (pcall
            (fn []
              (eval-str
                {:context opts.context
                 :code code
                 :passive? true
                 :on-result-raw result-fn}))))]

    (when (not ok?)
      (opts.cb locals))))
