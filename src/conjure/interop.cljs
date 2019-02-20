(ns conjure.interop
  (:require [goog.object :as go]))

(defn oset [o k v]
  (go/set o (name k) v))

(defn oget [o k]
  (go/get o (name k)))

(defn oget-in [o ks]
  (go/getValueByKeys o (into-array (map name ks))))

(defn oapply [o k & args]
  (apply (oget o k) args))

(defn oapply-in [o ks & args]
  (apply (oget-in o ks) args))

(defn eprintln [& args]
  (binding [*print-fn* *print-err-fn*]
    (apply println args)))
