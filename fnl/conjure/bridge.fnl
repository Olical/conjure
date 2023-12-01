(import-macros {: module : def : defn : defonce : def- : defn- : defonce- : wrap-last-expr : wrap-module-body : deftest} :nfnl.macros.aniseed)

(module conjure.bridge)

(defn viml->lua [m f opts]
  (.. "lua require('" m "')['" f "']("
      (or (and opts opts.args) "") ")"))

*module*
