(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(defn message! [tag & args]
  (apply nvim/out-write-line! (when tag (str "[" (name tag) "]")) args))

(defn error! [tag & args]
  (apply nvim/err-write-line! (when tag (str "[" (name tag) "]")) args))

(defn result! [tag result]
  (message! tag (name (:tag result)) "=>" (:val result)))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (nvim/err-write-line! (expound/expound-str spec form))
      nil)))
