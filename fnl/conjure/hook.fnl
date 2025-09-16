(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.hook))

;; These are originals defined by Conjure.
(set M.hook-fns (or M.hook-fns {}))

;; These are user defined overrides.
(set M.hook-override-fns (or M.hook-override-fns {}))

(fn M.define [name f]
  (core.assoc M.hook-fns name f))

(fn M.override [name f]
  (core.assoc M.hook-override-fns name f))

(fn M.get [name]
  (core.get M.hook-fns name))

(fn M.exec [name ...]
  (let [f (or (core.get M.hook-override-fns name)
              (core.get M.hook-fns name))]
    (if f
      (f ...)
      (error (str.join " " ["conjure.hook: Hook not found, can not exec" name])))))

M
