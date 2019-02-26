(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(defn aux! [conn result]
  (nvim/out-write-line! (str "[" (name (:tag conn)) "]") (name (:tag result)) "=>" (:val result)))

(defn result! [conn result]
  (nvim/out-write-line! (str "[" (name (:tag conn)) "]") (:val result)))

(defn message! [& args]
  (apply nvim/out-write-line! args))

(defn error! [& args]
  (apply nvim/err-write-line! args))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (nvim/err-write-line! (expound/expound-str spec form))
      nil)))
