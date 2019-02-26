(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.string :as str]
            [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(defn aux! [result]
  (nvim/out-write-line! (name (:tag result)) "=>" (:val result)))

(defn result! [conn result]
  (nvim/out-write-line! (str "[" (name (:tag conn)) "]") (:val result)))

(defn message! [& args]
  (apply nvim/out-write-line! "Conjure:" args))

(defn error! [& args]
  (apply nvim/err-write-line! "Conjure:" args))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (nvim/err-write-line! (expound/expound-str spec form))
      nil)))
