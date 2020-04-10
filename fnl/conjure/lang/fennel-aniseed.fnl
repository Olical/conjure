(module conjure.lang.fennel-aniseed
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            view conjure.aniseed.view
            ani-core aniseed.core
            ani-eval aniseed.eval
            ani-test aniseed.test
            lang conjure.lang
            mapping conjure.mapping
            text conjure.text
            log conjure.log
            extract conjure.extract}})

;; TODO Display all results from multi returns.

(def buf-suffix ".fnl")
(def context-pattern "[(]%s*module%s*(.-)[%s){]")
(def comment-prefix "; ")

(def config
  {:mappings {:run-buf-tests "tt"
              :run-all-tests "ta"}})

(defn- display [lines opts]
  (lang.with-filetype :fennel log.append lines opts))

(defn display-result [opts]
  (when opts
    (let [{: ok? : result} opts
          result-str (if ok?
                       (view.serialise result)
                       result)
          result-lines (str.split result-str "[^\n]+")] 
      (display (if ok?
                 result-lines
                 (a.map #(.. "; " $1) result-lines))))))

(defn eval-str [opts]
  (let [code (.. (.. "(module " (or opts.context "aniseed.user") ") ")
                 opts.code "\n")
        out (ani-core.with-out-str
              (fn []
                (let [(ok? result) (ani-eval.str code {:filename opts.file-path})]
                  (set opts.ok? ok?)
                  (set opts.result result))))]
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
  (let [res (ani-core.with-out-str f)]
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
        #(ani-test.run c)))))

(defn run-all-tests []
  (wrapped-test ["; run-all-tests"] ani-test.run-all))

(defn on-filetype []
  (mapping.buf :n config.mappings.run-buf-tests
               :conjure.lang.fennel-aniseed :run-buf-tests)
  (mapping.buf :n config.mappings.run-all-tests
               :conjure.lang.fennel-aniseed :run-all-tests))
