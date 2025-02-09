;; [nfnl-macro]

(fn time [...]
  `(let [start# (vim.loop.hrtime)
         result# (do ,...)
         end# (vim.loop.hrtime)]
     (print (.. "Elapsed time: " (/ (- end# start#) 1000000) " msecs"))
     result#))

(fn conditional-let [branch bindings ...]
  (assert (= 2 (length bindings)) "expected a single binding pair")

  (let [[bind-expr value-expr] bindings]
    (if
      ;; Simple symbols
      ;; [foo bar]
      (sym? bind-expr)
      `(let [,bind-expr ,value-expr]
         (,branch ,bind-expr ,...))

      ;; List / values destructure
      ;; [(a b) c]
      (list? bind-expr)
      (do
        ;; Even if the user isn't using the first slot, we will.
        ;; [(_ val) (pcall #:foo)]
        ;;  => [(bindGENSYM12345 val) (pcall #:foo)]
        (when (= `_ (. bind-expr 1))
          (tset bind-expr 1 (gensym "bind")))

        `(let [,bind-expr ,value-expr]
           (,branch ,(. bind-expr 1) ,...)))

      ;; Sequential and associative table destructure
      ;; [[a b] c]
      ;; [{: a : b} c]
      (table? bind-expr)
      `(let [value# ,value-expr
             ,bind-expr (or value# {})]
         (,branch value# ,...))

      ;; We should never get here, but just in case.
      (assert (.. "unknown bind-expr type: " (type bind-expr))))))

(fn if-let [bindings ...]
  (assert (<= (length [...]) 2) (.. "if-let does not support more than two branches"))
  (conditional-let `if bindings ...))

(fn when-let [bindings ...]
  (conditional-let `when bindings ...))

{: time
 : if-let
 : when-let}
