(ns conjure.util
  (:require [clojure.walk :as w]
            [camel-snake-kebab.core :as csk]))

(defn ->js [m]
  (letfn [(map-key [[k v]]
            (if (keyword? k)
              [(csk/->camelCaseString k) v]
              [k v]))]
    (clj->js
      (w/postwalk
        (fn [x] (if (map? x)
                  (into {} (map map-key x))
                  x))
        m))))
