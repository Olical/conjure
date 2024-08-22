(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))

(fn create [xs prev]
  (when (not (a.empty? xs))
    (let [rest (a.rest xs)
          node {}]
      (a.assoc node :val (a.first xs))
      (a.assoc node :prev prev)
      (a.assoc node :next (create rest node)))))

(fn val [l]
  (-?> l (a.get :val)))

(fn next [l]
  (-?> l (a.get :next)))

(fn prev [l]
  (-?> l (a.get :prev)))

(fn first [l]
  (var c l)
  (while (prev c)
    (set c (prev c)))
  c)

(fn last [l]
  (var c l)
  (while (next c)
    (set c (next c)))
  c)

(fn until [f l]
  (var c l)
  (var r false)
  (fn step []
    (set r (f c))
    r)
  (while (and c (not (step)))
    (set c (next c)))
  (when r
    c))

(fn cycle [l]
  (let [start (first l)
        end (last l)]
    (a.assoc start :prev end)
    (a.assoc end :next start)
    l))

{
 : create
 : val
 : next
 : prev
 : first
 : last
 : until
 : cycle
 }

