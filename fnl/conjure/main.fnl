(module conjure.main
  {require {mapping conjure.mapping
            config conjure.config
            config2 conjure.config2}})

(defn main []
  ;; TODO Swap filetypes for (a.keys (config2.get-in [:filetype_client]))
  (mapping.init (config.filetypes)))
