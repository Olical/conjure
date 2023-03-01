(module conjure.hook
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string}})

;; These are originals defined by Conjure.
(defonce hook-fns {})

;; These are user defined overrides.
(defonce hook-override-fns {})

(defn define [name f]
  (a.assoc hook-fns name f))

(defn override [name f]
  (a.assoc hook-override-fns name f))

(defn get [name]
  (a.get hook-fns name))

(defn exec [name ...]
  (let [f (or (a.get hook-override-fns name)
              (a.get hook-fns name))]
    (if f
      (f ...)
      (error (str.join " " ["conjure.hook: Hook not found, can not exec" name])))))
