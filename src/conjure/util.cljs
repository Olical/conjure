(ns conjure.util
  (:require [clojure.walk :as w]
            [clojure.string :as str]
            [camel-snake-kebab.core :as csk]
            [applied-science.js-interop :as j]))

(defn join [args]
  (str/join " " (remove nil? args)))

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

(defn now []
  (j/call js/Date :now))
