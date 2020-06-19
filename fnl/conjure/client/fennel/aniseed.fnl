(module conjure.client.fennel.aniseed
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            view conjure.aniseed.view
            client conjure.client
            mapping conjure.mapping
            text conjure.text
            log conjure.log
            extract conjure.extract}})

(def buf-suffix ".fnl")
(def context-pattern "%(%s*module%s+(.-)[%s){]")
(def comment-prefix "; ")

(def config
  {:mappings {:run-buf-tests "tt"
              :run-all-tests "ta"}
   :aniseed-module-prefix :conjure.aniseed.
   :use-metadata? true})

(def- ani-aliases
  {:nu :nvim.util})

(defn- ani [mod-name f-name]
  (let [mod-name (a.get ani-aliases mod-name mod-name)
        mod (require (.. config.aniseed-module-prefix mod-name))]
    (if f-name
      (a.get mod f-name)
      mod)))

(defn- anic [mod f-name ...]
  ((ani mod f-name) ...))

(defn- display [lines opts]
  (client.with-filetype :fennel log.append lines opts))

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
        (display (if ok?
                   result-lines
                   (a.map #(.. "; " $1) result-lines))))
      (when opts.on-result
        (opts.on-result result-str)))))

(defn eval-str [opts]
  (let [code (.. (.. "(module " (or opts.context "aniseed.user") ") ")
                 opts.code "\n")
        out (anic :nu :with-out-str
                  (fn []
                    (when config.use-metadata?
                      (set package.loaded.fennel (ani :fennel)))

                    (let [[ok? & results]
                          [(anic :eval :str code
                                 {:filename opts.file-path
                                  :useMetadata config.use-metadata?})]]
                      (set opts.ok? ok?)
                      (set opts.results results))))]
    (when (not (a.empty? out))
      (display (text.prefixed-lines (text.trim-last-newline out) "; (out) ")))
    (display-result opts)))

(defn doc-str [opts]
  (a.assoc opts :code (.. "(doc " opts.code ")"))
  (eval-str opts))

(defn eval-file [opts]
  (set opts.code (a.slurp opts.file-path))
  (when opts.code
    (eval-str opts)))

(defn- wrapped-test [req-lines f]
  (display req-lines {:break? true})
  (let [res (anic :nu :with-out-str f)]
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
        #(anic :test :run c)))))

(defn run-all-tests []
  (wrapped-test ["; run-all-tests"] (ani :test :run-all)))

(defn on-filetype []
  (mapping.buf :n config.mappings.run-buf-tests
               :conjure.client.fennel.aniseed :run-buf-tests)
  (mapping.buf :n config.mappings.run-all-tests
               :conjure.client.fennel.aniseed :run-all-tests))
