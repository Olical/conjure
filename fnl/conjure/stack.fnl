(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))

(fn push [s v]
  (table.insert s v)
  s)

(fn pop [s]
  (table.remove s)
  s)

(fn peek [s]
  (a.last s))

{
 : push
 : pop
 : peek
 }

