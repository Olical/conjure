(ns conjure.util
  (:require [clojure.walk :as w]
            [clojure.string :as str]
            [applied-science.js-interop :as j]
            [camel-snake-kebab.core :as csk]))

(defn log [& args]
  (j/call js/console :log (str/join " " args))
  (first args))

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
