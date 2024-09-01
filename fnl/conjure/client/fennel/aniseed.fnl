(local {: autoload} (require :nfnl.module))
(local nvim (autoload :conjure.aniseed.nvim))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local view (autoload :conjure.aniseed.view))
(local client (autoload :conjure.client))
(local mapping (autoload :conjure.mapping))
(local fs (autoload :conjure.fs))
(local text (autoload :conjure.text))
(local log (autoload :conjure.log))
(local config (autoload :conjure.config))
(local extract (autoload :conjure.extract))
(local ts (autoload :conjure.tree-sitter))

(local comment-node? ts.lisp-comment-node?)
(fn form-node? [node]
  (ts.node-surrounded-by-form-pair-chars? node [["#(" ")"]]))

(local buf-suffix ".fnl")
(local context-pattern "%(%s*module%s+(.-)[%s){]")
(local comment-prefix "; ")

(config.merge
  {:client
   {:fennel
    {:aniseed
     {:aniseed_module_prefix :conjure.aniseed.
      :use_metadata true}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
   {:client
    {:fennel
     {:aniseed
      {:mapping {:run_buf_tests "tt"
                 :run_all_tests "ta"
                 :reset_repl "rr"
                 :reset_all_repls "ra"}}}}}))

(local cfg (config.get-in-fn [:client :fennel :aniseed]))

(local ani-aliases
  {:nu :nvim.util})

(fn ani [mod-name f-name]
  (let [mod-name (a.get ani-aliases mod-name mod-name)
        mod (require (.. (cfg [:aniseed_module_prefix]) mod-name))]
    (if f-name
      (a.get mod f-name)
      mod)))

(fn anic [mod f-name ...]
  ((ani mod f-name) ...))

(local repls {})

(fn reset-repl [filename]
  (let [filename (or filename (fs.localise-path (extract.file-path)))]
    (tset repls filename nil)
    (log.append [(.. "; Reset REPL for " filename)] {:break? true})))

(fn reset-all-repls []
  (a.run!
    (fn [filename]
      (tset repls filename nil))
    (a.keys repls))
  (log.append [(.. "; Reset all REPLs")] {:break? true}))

(local default-module-name "conjure.user")

(fn module-name [context file-path]
  (if
    context context
    file-path (or (fs.file-path->module-name file-path) default-module-name)
    default-module-name))

(fn repl [opts]
  (let [filename (a.get opts :filename)]
    (or ;; Reuse an existing REPL.
        (and (not (a.get opts :fresh?)) (a.get repls filename))

        ;; Build a new REPL.
        (let [;; Shared between the error-handler function (created at the same time as the REPL).
              ;; And each individual eval call. This allows us to capture errors from different call stacks.
              ret {}

              ;; Set up the error-handler function on the creation of the REPL.
              ;; Will place any errors in the ret table.
              _ (tset opts :error-handler
                      (fn [err]
                        (set ret.ok? false)
                        (set ret.results [err])))

              ;; Instantiate the raw REPL, we'll wrap this a little first though.
              eval! (anic :eval :repl opts)

              ;; Build our REPL function.
              repl (fn [code]
                     ;; Reset the ret table before running anything.
                     (set ret.ok? nil)
                     (set ret.results nil)

                     ;; Run the code, either capturing a result or an error.
                     ;; If there's no error in ret we can place the results in the ret table.
                     (let [results (eval! code)]
                       (when (a.nil? ret.ok?)
                         (set ret.ok? true)
                         (set ret.results results))
                       ;; Finally this good or bad result is returned.
                       ret))]

          ;; Set up the REPL in the module context.
          (repl (.. "(module " (a.get opts :moduleName) ")"))

          ;; Store the REPL for future reuse.
          (tset repls filename repl)

          ;; Return the new REPL!
          repl))))

(fn display-result [opts]
  (when opts
    (let [{: ok? : results} opts
          result-str (or
                       (if ok?
                         (when (not (a.empty? results))
                           (str.join "\n" (a.map view.serialise results)))
                         (a.first results))
                       "nil")
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

(fn eval-str [opts]
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

                                            ;; Restart the REPL if...
                                            :fresh? (or ;; We eval an entire file or buffer.
                                                        (= :file opts.origin) (= :buf opts.origin)

                                                        ;; The user is evaluating the module form.
                                                        (text.starts-with opts.code (.. "(module " (or opts.context ""))))})
                               {: ok? : results} (eval! (.. opts.code "\n"))]

                           (when (not= :ok (a.get-in (eval! ":ok\n") [:results 1]))
                             (log.append ["; REPL appears to be stuck, did you open a string or form and not close it?"
                                          (str.join ["; You can use " (config.get-in [:mapping :prefix]) (cfg [:mapping :reset_repl]) " to reset and repair the REPL."])]))

                           (set opts.ok? ok?)
                           (set opts.results results))))]
         (when (not (a.empty? out))
           (log.append (text.prefixed-lines (text.trim-last-newline out) "; (out) ")))
         (display-result opts))))))

(fn doc-str [opts]
  (a.assoc opts :code (.. ",doc " opts.code))
  (eval-str opts))

(fn eval-file [opts]
  (set opts.code (a.slurp opts.file-path))
  (when opts.code
    (eval-str opts)))

(fn wrapped-test [req-lines f]
  (log.append req-lines {:break? true})
  (let [res (anic :nu :with-out-str f)]
    (log.append
      (-> (if (= "" res)
            "No results."
            res)
          (text.prefixed-lines "; ")))))

(fn run-buf-tests []
  (let [c (extract.context)]
    (when c
      (wrapped-test
        [(.. "; run-buf-tests (" c ")")]
        #(anic :test :run c)))))

(fn run-all-tests []
  (wrapped-test ["; run-all-tests"] (ani :test :run-all)))

(fn on-filetype []
  (mapping.buf
    :FnlRunBufTests (cfg [:mapping :run_buf_tests])
    #(run-buf-tests)
    {:desc "Run loaded buffer tests"})

  (mapping.buf
    :FnlRunAllTests (cfg [:mapping :run_all_tests])
    #(run-all-tests)
    {:desc "Run all loaded tests"})

  (mapping.buf
    :FnlResetREPL (cfg [:mapping :reset_repl])
    #(reset-repl)
    {:desc "Reset the current REPL state"})

  (mapping.buf
    :FnlResetAllREPLs (cfg [:mapping :reset_all_repls])
    #(reset-all-repls)
    {:desc "Reset all REPL states"}))

(fn value->completions [x]
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

(fn completions [opts]
  (let [code (when (not (str.blank? opts.prefix))
               (let [prefix (string.gsub opts.prefix ".$" "")]
                 (.. "((. (require :" *module-name* ") :value->completions) " prefix ")")))
        mods (value->completions package.loaded)
        locals (let [(ok? m) (pcall #(require opts.context))]
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
                {:file-path opts.file-path
                 :context opts.context
                 :code code
                 :passive? true
                 :on-result-raw result-fn}))))]

    (when (not ok?)
      (opts.cb locals))))

{: buf-suffix
 : comment-node?
 : comment-prefix
 : completions
 : context-pattern
 : default-module-name
 : display-result
 : doc-str
 : eval-file
 : eval-str
 : form-node?
 : module-name
 : on-filetype
 : repl
 : reset-all-repls
 : reset-repl
 : run-all-tests
 : run-buf-tests
 : value->completions }
