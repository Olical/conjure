(ns conjure.async
   (:require [cljs.core.async :as a]
             [cljs.core.async.impl.protocols :as async-prot]
             [applied-science.js-interop :as j])
   (:require-macros [conjure.async :refer [go]]))

(defonce error-chan (a/chan))

(defn ->chan [p]
  (when (j/get p :then)
    (let [c (a/promise-chan)]
      (j/call p :then
              (fn [v]
                (go
                  (if (nil? v)
                    (a/close! c)
                    (a/>! c v)))))
      c)))

(defn chan? [x]
  (satisfies? async-prot/ReadPort x))

(defn ->promise [c]
  (when (chan? c)
    (js/Promise.
      (fn [res rej]
        (a/go
          (try
            (res (a/<! c))
            (catch :default e
              (rej e))))))))
