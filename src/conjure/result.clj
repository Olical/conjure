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

(defn error? [res]
  (= (kind res) :error))

(defn ok? [res]
  (= (kind res) :ok))

(defn error [res]
  (when (error? res)
    (value res)))

(defn ok [res]
  (when (ok? res)
    (value res)))
