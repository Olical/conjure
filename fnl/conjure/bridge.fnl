(module conjure.bridge)

(defn viml->lua [m f opts]
  (.. "lua require('" m "')['" f "']("
      (or (and opts opts.args) "") ")"))
