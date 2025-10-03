(local {: autoload : define} (require :conjure.nfnl.module))
(local mapping (autoload :conjure.mapping))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))

(local M (define :conjure.main))

(fn M.main []
  (mapping.init (config.filetypes))
  (log.setup-auto-flush))

M
