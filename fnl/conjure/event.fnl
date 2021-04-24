(module conjure.event
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             text conjure.text
             client conjure.client
             str conjure.aniseed.string}})

(defn emit [...]
  (let [names (a.map text.upper-first [...])]
    (client.schedule
      (fn []
        (while (not (a.empty? names))
          (nvim.ex.doautocmd :User (.. :Conjure (str.join names)))
          (table.remove names)))))
  nil)
