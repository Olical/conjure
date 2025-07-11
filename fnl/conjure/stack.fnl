(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))

(local M (define :conjure.stack))

(fn M.push [s v]
  (table.insert s v)
  s)

(fn M.pop [s]
  (table.remove s)
  s)

(fn M.peek [s]
  (core.last s))

M

