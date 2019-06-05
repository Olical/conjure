(ns conjure.config
  "Tools to load all relevant  .conjure.edn files.
  They're used to manage connection configuration."
  (:require [clojure.edn :as edn]
            [medley.core :as m]
            [me.raynes.fs :as fs]))

(def edn-opts
  {:readers {'regex re-pattern
             'slurp-edn (fn [path]
                         (edn/read-string (slurp path)))}})

(defn fetch []
  (->> (conj (fs/parents ".") fs/*cwd*)
       (reverse)
       (sequence
         (comp (map #(fs/file % ".conjure.edn"))
               (filter (every-pred fs/file? fs/readable?))
               (map slurp)
               (map #(edn/read-string edn-opts %))))
       (apply m/deep-merge)))
