(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(defn result! [result]
  (nvim/out-write-line! (:val result)))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (nvim/err-write-line! (expound/expound-str spec form))
      nil)))
