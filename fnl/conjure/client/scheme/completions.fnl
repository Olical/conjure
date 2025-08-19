(local {: autoload : define} (require :conjure.nfnl.module))
(local keywords (autoload :conjure.client.scheme.keywords))
(local config (autoload :conjure.config))
(local util (autoload :conjure.util))
(local tsc (autoload :conjure.tree-sitter-completions))

(local M (define :conjure.client.scheme.completions))

(fn get-lang-key-from-stdio-command [command]
  (if 
    (string.match command "mit") :mit
    (string.match command "petite") :chez
    (string.match command "csi") :chicken
    :common))

(fn M.get-completions [prefix]
  (let [stdio-command (config.get-in [:client :scheme :stdio :command])
        lang-key (get-lang-key-from-stdio-command stdio-command)
        keyword-set (keywords.get-set lang-key) 
        prefix-filter (util.make-prefix-filter prefix)]
    (prefix-filter (util.concat-nodup
      (tsc.get-completions-at-cursor :scheme :scheme)
      keyword-set))))

M
