(module conjure.api
  {require {eval conjure.eval
            log conjure.log
            client conjure.client
            a conjure.aniseed.core}})

(defn with_filetype [ft f ...]
  (client.with-filetype ft f ...))

(defn eval_str [opts]
  "Evaluate a string of code (opts.code) and give the result to
  opts.on-result. If you don't want the user to see the eval or have the result
  placed in their result register, set opts.passive? to true.
  Set opts.origin to the name of your tool if you want to have it displayed in
  the log when opts.passive? is false."
  (eval.eval-str
    (a.merge {:origin :api} opts)))

(defn display [lines opts]
  "Append lines to the log of the current filetype."
  (log.append lines opts))

; (with_filetype
;   :janet
;   eval_str
;   {:code "(+ 10 20)"
;    :passive? true
;    :on-result (fn [r]
;                 (print "GOT A RESULT" r))})

; (with_filetype
;   :janet
;   display
;   [";; Hello, World!"])
