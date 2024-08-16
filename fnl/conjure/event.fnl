(local {: autoload} (require :nfnl.module))
(local nvim (autoload :conjure.aniseed.nvim))
(local a (autoload :conjure.aniseed.core))
(local text (autoload :conjure.text))
(local client (autoload :conjure.client))
(local str (autoload :conjure.aniseed.string))

(fn emit [...]
  (let [names (a.map text.upper-first [...])]
    (client.schedule
      (fn []
        (while (not (a.empty? names))
          (nvim.ex.doautocmd :User (.. :Conjure (str.join names)))
          (table.remove names)))))
  nil)

{: emit}
