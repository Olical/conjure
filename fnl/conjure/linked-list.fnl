(module conjure.linked-list
  {require {a conjure.aniseed.core}})

(defn create [xs prev]
  (when (not (a.empty? xs))
    (let [rest (a.rest xs)
          node {}]
      (a.assoc node :val (a.first xs))
      (a.assoc node :prev prev)
      (a.assoc node :next (create rest node)))))

(defn val [l]
  (-?> l (a.get :val)))

(defn next [l]
  (-?> l (a.get :next)))

(defn prev [l]
  (-?> l (a.get :prev)))

(defn first [l]
  (var c l)
  (while (prev c)
    (set c (prev c)))
  c)

(defn last [l]
  (var c l)
  (while (next c)
    (set c (next c)))
  c)

(defn until [f l]
  (var c l)
  (var r false)
  (fn step []
    (set r (f c))
    r)
  (while (and c (not (step)))
    (set c (next c)))
  (when r
    c))

(defn cycle [l]
  (let [start (first l)
        end (last l)]
    (a.assoc start :prev end)
    (a.assoc end :next start)
    l))
