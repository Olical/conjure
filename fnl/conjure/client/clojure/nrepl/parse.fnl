(local {: define} (require :conjure.nfnl.module))

(local M (define :conjure.client.clojure.nrepl.parse))

(fn M.strip-meta [s]
  (-?> s
       (string.gsub "%^:.-%s+" "")
       (string.gsub "%^%b{}%s+" "")))

(fn M.strip-comments [s]
  (-?> s
       (string.gsub ";.-[\n$]" "")))

(fn M.strip-shebang [s]
  (-?> s
       (string.gsub "^#![^\n]*\n" "")))

M
