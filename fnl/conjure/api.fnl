(module conjure.api
  {require {eval conjure.eval
            log conjure.log
            client conjure.client
            a conjure.aniseed.core}})

(defn eval-str [opts]
  "Evaluate a string of code (opts.code) and give the result to
  opts.on-result. If you don't want the user to see the eval or have the result
  placed in their result register, set opts.passive? to true.
  Set opts.origin to the name of your tool if you want to have it displayed in
  the log when opts.passive? is false."

  (eval.eval-str
    (a.merge {:origin :api} opts)))

(defn display [lines opts]
  "Append lines to the log of a specific filetype specified by opts.filetype."

  (when (not (a.get opts :filetype))
    (error "opts.filetype must be set"))

  (client.with-filetype
    opts.filetype
    log.append lines opts))

(comment
  (eval-str
    {:code "(+ 10 20)"
     :passive? true
     :on-result (fn [r]
                  (print "GOT A RESULT" r))})

  (display [";; Hello, World!"]
           {:filetype :fennel}))
