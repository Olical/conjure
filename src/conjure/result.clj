(ns conjure.result)

;; When I kill the need for this namespace a lot of things can be refactored.
;; For instance, doc lookup can be run almost blindly, errors can be handled nicely.
;; Right now I basically can't catch errors from macro expansion time.

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
