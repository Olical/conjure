(module conjure.main
  {require {mapping conjure.mapping
            config conjure.config
            config2 conjure.config2}})

(defn main []
  (config2.init)

  ;; TODO Swap filetypes for (a.keys (config2.get-in [:clients]))
  (mapping.init (config.filetypes)))
