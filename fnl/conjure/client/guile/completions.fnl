(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local keywords (autoload :conjure.client.scheme.keywords))
(local util (autoload :conjure.util))
(local tsc (autoload :conjure.tree-sitter-completions))
(local res (autoload :conjure.resources))

(local M (define :conjure.client.guile.completions))

(set M.guile-repl-completion-code (res.get-resource-contents "client/guile/completion.scm"))

(fn M.build-completion-request [prefix]
  (.. "(%conjure:get-guile-completions " (a.pr-str prefix) ")"))

(fn parse-guile-completion-result [rs]
  (icollect [token (string.gmatch rs "\"([^\"^%s]+)\"")]
    token))

(fn M.format-results [rs]
  (let [cmpls (parse-guile-completion-result rs)
        last (table.remove cmpls)]
    (table.insert cmpls 1 last)
    cmpls))

(fn M.get-static-completions [prefix]
  (let [keyword-set (keywords.get-set :guile)
        prefix-filter (util.make-prefix-filter prefix)]
    (prefix-filter (util.concat-nodup
      (tsc.get-completions-at-cursor :scheme :scheme)
      keyword-set))))

M
