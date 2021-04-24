(module conjure.main
  {autoload {mapping conjure.mapping
             config conjure.config}})

(defn main []
  (mapping.init (config.filetypes)))
