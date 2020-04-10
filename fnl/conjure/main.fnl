(module conjure.main
  {require {mapping conjure.mapping
            config conjure.config}})

(defn main []
  (mapping.setup-filetypes (config.filetypes)))
