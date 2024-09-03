(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))

(local get-stack-key :conjure.dynamic/get-stack)

(fn assert-value-function! [value]
  (when (not= :function (type value))
    (error "conjure.dynamic values must always be wrapped in a function")))

(fn new [base-value]
  (assert-value-function! base-value)
  (var stack [base-value])
  (fn [x ...]
    (if (= get-stack-key x) stack
      ((a.last stack) x ...))))

(fn run-binds! [f binds]
  (a.map-indexed
    (fn [[dyn new-value]]
      (assert-value-function! new-value)
      (f (dyn get-stack-key) new-value))
    binds))

(fn bind [binds f ...]
  (run-binds! table.insert binds)
  (let [(ok? result) (pcall f ...)]
    (run-binds! #(table.remove $1) binds)
    (if ok?
      result
      (error result))))

(fn set! [dyn new-value]
  (assert-value-function! new-value)
  (let [stack (dyn get-stack-key)
        depth (a.count stack)]
    (a.assoc stack depth new-value))
  nil)

(fn set-root! [dyn new-value]
  (assert-value-function! new-value)
  (a.assoc (dyn get-stack-key) 1 new-value)
  nil)

{: new
 : bind
 : set!
 : set-root!}
