(module conjure.stack
  {autoload {a conjure.aniseed.core}})

(defn push [s v]
  (table.insert s v)
  s)

(defn pop [s]
  (table.remove s)
  s)

(defn peek [s]
  (a.last s))
