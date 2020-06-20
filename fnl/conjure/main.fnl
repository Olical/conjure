(module conjure.main
  {require {mapping conjure.mapping
            config conjure.config2}})

(defn main []
  (mapping.init (config.filetypes)))
