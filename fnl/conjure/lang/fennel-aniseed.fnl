(module conjure.lang.fennel-aniseed
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            view conjure.aniseed.view
            lang conjure.lang
            mapping conjure.mapping
            text conjure.text
            log conjure.log
            extract conjure.extract}})

(def buf-suffix ".fnl")
(def context-pattern "[(]%s*module%s*(.-)[%s){]")
(def comment-prefix "; ")

(def config
  {:mappings {:run-buf-tests "tt"
              :run-all-tests "ta"}
   :aniseed-module-prefix :conjure.aniseed.
   :use-metadata? true})

(def- ani
  (let [req #(require (.. config.aniseed-module-prefix $1))]
    {:core (req :core)
     :nu (req :nvim.util)
     :eval (req :eval)
     :test (req :test)
     :fennel (req :fennel)}))

(defn- display [lines opts]
  (lang.with-filetype :fennel log.append lines opts))

(defn display-result [opts]
  (when opts
    (let [{: ok? : results} opts
          result-str (if ok?
                       (if (a.empty? results)
                         "nil"
                         (str.join "\n" (a.map view.serialise results)))
                       (a.first results))
          result-lines (str.split result-str "[^\n]+")] 
      (display (if ok?
                 result-lines
                 (a.map #(.. "; " $1) result-lines))))))

(defn eval-str [opts]
  (let [code (.. (.. "(module " (or opts.context "aniseed.user") ") ")
                 opts.code "\n")
        out (ani.nu.with-out-str
              (fn []
                (when config.use-metadata?
                  (set package.loaded.fennel ani.fennel))

                (let [[ok? & results]
                      [(ani.eval.str code
                                     {:filename opts.file-path
                                      :useMetadata config.use-metadata?})]]
                  (set opts.ok? ok?)
                  (set opts.results results))))]
    (when (not (a.empty? out))
      (display (text.prefixed-lines out "; (out) ")))
    (display-result opts)))

(defn doc-str [opts]
  (a.assoc opts :code (.. "(doc " opts.code ")"))
  (eval-str opts))

(defn- not-implemented []
  (display ["; Not implemented for conjure.lang.fennel-aniseed"]))

(defn def-str [opts]
  (not-implemented))

(defn eval-file [opts]
  (set opts.code (a.slurp opts.file-path))
  (when opts.code
    (eval-str opts)))

(defn- wrapped-test [req-lines f]
  (display req-lines {:break? true})
  (let [res (ani.nu.with-out-str f)]
    (display
      (-> (if (= "" res)
            "No results."
            res)
          (text.prefixed-lines "; ")))))

(defn run-buf-tests []
  (let [c (extract.context)]
    (when c
      (wrapped-test
        [(.. "; run-buf-tests (" c ")")]
        #(ani.test.run c)))))

(defn run-all-tests []
  (wrapped-test ["; run-all-tests"] ani.test.run-all))

(defn on-filetype []
  (mapping.buf :n config.mappings.run-buf-tests
               :conjure.lang.fennel-aniseed :run-buf-tests)
  (mapping.buf :n config.mappings.run-all-tests
               :conjure.lang.fennel-aniseed :run-all-tests))
