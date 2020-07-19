(module conjure.dynamic
  {require {a conjure.aniseed.core}})

(def- stack-key :conjure.dynamic/stack)

(defn new [base-value]
  (let [stack [base-value]]
    (fn [x ...]
      (if (= stack-key x)
        stack
        ((a.last stack) x ...)))))

(defn- run-binds! [f binds]
  (a.map-indexed
    (fn [[dyn new-value]]
       (f (dyn stack-key) new-value))
    binds))

(defn bind [binds f ...]
  (run-binds! table.insert binds)
  (let [(ok? result) (pcall f ...)]
    (run-binds! #(table.remove $1) binds)
    (if ok?
      result
      (error result))))
