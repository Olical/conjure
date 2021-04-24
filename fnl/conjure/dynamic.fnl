(module conjure.dynamic
  {autoload {a conjure.aniseed.core}})

(def- get-stack-key :conjure.dynamic/get-stack)

(defn- assert-value-function! [value]
  (when (not= :function (type value))
    (error "conjure.dynamic values must always be wrapped in a function")))

(defn new [base-value]
  (assert-value-function! base-value)
  (var stack [base-value])
  (fn [x ...]
    (if (= get-stack-key x) stack
      ((a.last stack) x ...))))

(defn- run-binds! [f binds]
  (a.map-indexed
    (fn [[dyn new-value]]
      (assert-value-function! new-value)
      (f (dyn get-stack-key) new-value))
    binds))

(defn bind [binds f ...]
  (run-binds! table.insert binds)
  (let [(ok? result) (pcall f ...)]
    (run-binds! #(table.remove $1) binds)
    (if ok?
      result
      (error result))))

(defn set! [dyn new-value]
  (assert-value-function! new-value)
  (let [stack (dyn get-stack-key)
        depth (a.count stack)]
    (a.assoc stack depth new-value))
  nil)

(defn set-root! [dyn new-value]
  (assert-value-function! new-value)
  (a.assoc (dyn get-stack-key) 1 new-value)
  nil)
