(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))

;; These are originals defined by Conjure.
(local hook-fns {})

;; These are user defined overrides.
(local hook-override-fns {})

(fn define [name f]
  (a.assoc hook-fns name f))

(fn override [name f]
  (a.assoc hook-override-fns name f))

(fn get [name]
  (a.get hook-fns name))

(fn exec [name ...]
  (let [f (or (a.get hook-override-fns name)
              (a.get hook-fns name))]
    (if f
      (f ...)
      (error (str.join " " ["conjure.hook: Hook not found, can not exec" name])))))

{
 : hook-fns
 : hook-override-fns
 : define
 : override
 : get
 : exec
 }
