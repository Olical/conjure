(local {: autoload : define} (require :conjure.nfnl.module))
(local a (require :conjure.nfnl.core))
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
        ts-cmpl (tsc.get-completions-at-cursor :scheme :scheme)
        all-cmpl (a.concat ts-cmpl keyword-set)
        distinct-cmpl (util.ordered-distinct all-cmpl)
        prefix-filter (tsc.make-prefix-filter prefix)]
    (prefix-filter distinct-cmpl)))

M
