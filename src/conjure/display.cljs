(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(defn result! [result]
  (nvim/out-write-line! (str "RESULT: " (:val result))))

(defn aux! [result]
  (nvim/out-write-line! (str "AUX: " (:val result))))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (nvim/err-write-line! (expound/expound-str spec form))
      nil)))
