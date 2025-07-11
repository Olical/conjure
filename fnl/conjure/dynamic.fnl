(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))

(local M (define :conjure.dynamic))

(local get-stack-key :conjure.dynamic/get-stack)

(fn assert-value-function! [value]
  (when (not= :function (type value))
    (error "conjure.dynamic values must always be wrapped in a function")))

(fn M.new [base-value]
  (assert-value-function! base-value)
  (let [stack [base-value]]
    (fn [x ...]
      (if (= get-stack-key x)
        stack
        ((core.last stack) x ...)))))

(fn run-binds! [f binds]
  (core.map-indexed
    (fn [[dyn new-value]]
      (assert-value-function! new-value)
      (f (dyn get-stack-key) new-value))
    binds))

(fn M.bind [binds f ...]
  (run-binds! table.insert binds)
  (let [(ok? result) (pcall f ...)]
    (run-binds! #(table.remove $1) binds)
    (if ok?
      result
      (error result))))

(fn M.set! [dyn new-value]
  (assert-value-function! new-value)
  (let [stack (dyn get-stack-key)
        depth (core.count stack)]
    (core.assoc stack depth new-value))
  nil)

(fn M.set-root! [dyn new-value]
  (assert-value-function! new-value)
  (core.assoc (dyn get-stack-key) 1 new-value)
  nil)

M
