(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [conjure.nvim :as nvim]))

(defn result! [result]
  (nvim/out-write-line! (:val result)))
