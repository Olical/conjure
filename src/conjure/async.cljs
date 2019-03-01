(ns conjure.async
   (:require [cljs.core.async :as a]
             [applied-science.js-interop :as j])
   (:require-macros [conjure.async :refer [go]]))

(defonce error-chan (a/chan))

(defn ->chan [p]
   (let [c (a/promise-chan)]
      (j/call p :then
              (fn [v]
                 (go
                    (if (nil? v)
                       (a/close! c)
                       (a/>! c v)))))
      c))
