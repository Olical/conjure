(ns conjure.util
  (:require [clojure.walk :as w]
            [clojure.string :as str]
            [cljs.core.async :as a]
            [applied-science.js-interop :as j]
            [promesa.core :as p]
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

(defn ->promise [c]
  (p/promise
    (fn [done _]
      (a/go (done (when c (a/<! c)))))))

(defn ->chan [p]
  (let [c (a/chan)]
    (p/map
      (fn [v]
        (a/go
          (if v
            (a/>! c v)
            (a/close! c))))
      p)
    c))
