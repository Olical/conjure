(ns conjure.result)

(defn- result? [v]
  (and (vector? v)
       (= (count v) 2)
       (keyword? (first v))))

(defn kind [res]
  (when (result? res)
    (first res)))

(defn value [res]
  (when (result? res)
    (second res)))
