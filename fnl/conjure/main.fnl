(import-macros {: module : def : defn : defonce : def- : defn- : defonce- : wrap-last-expr : wrap-module-body : deftest} :nfnl.macros.aniseed)

(module conjure.main
  {autoload {mapping conjure.mapping
             config conjure.config}})

(defn main []
  (mapping.init (config.filetypes)))

*module*
