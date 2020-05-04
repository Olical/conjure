(module conjure.fs
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core}})

(defn resolve-in-parent-dirs [path]
  (let [resolved (nvim.fn.findfile path ".;")]
    (when (not (a.empty? resolved))
      resolved)))
