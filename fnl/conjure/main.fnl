(local {: autoload} (require :nfnl.module))
(local mapping (autoload :conjure.mapping))
(local config (autoload :conjure.config))

(fn main []
  (mapping.init (config.filetypes)))

{: main }
