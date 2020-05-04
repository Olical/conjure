(module conjure.main
  {require {mapping conjure.mapping
            config conjure.config}})

(defn main []
  (mapping.init (config.filetypes)))
