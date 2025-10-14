(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local text (autoload :conjure.text))
(local client (autoload :conjure.client))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.event))

(fn M.emit [...]
  (let [names (core.map text.upper-first [...])]
    (client.schedule
      (fn []
        (while (not (core.empty? names))
          (vim.api.nvim_exec_autocmds :User (.. :Conjure (str.join names)))
          (table.remove names)))))
  nil)

M
