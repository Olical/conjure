(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.core.core))

(local M (define :conjure.linked-list))

(fn M.create [xs prev]
  (when (not (core.empty? xs))
    (let [rest (core.rest xs)
          node {}]
      (core.assoc node :val (core.first xs))
      (core.assoc node :prev prev)
      (core.assoc node :next (M.create rest node)))))

(fn M.val [l]
  (-?> l (core.get :val)))

(fn M.next [l]
  (-?> l (core.get :next)))

(fn M.prev [l]
  (-?> l (core.get :prev)))

(fn M.first [l]
  (var c l)
  (while (M.prev c)
    (set c (M.prev c)))
  c)

(fn M.last [l]
  (var c l)
  (while (next c)
    (set c (next c)))
  c)

(fn M.until [f l]
  (var c l)
  (var r false)
  (fn step []
    (set r (f c))
    r)
  (while (and c (not (step)))
    (set c (next c)))
  (when r
    c))

(fn M.cycle [l]
  (let [start (M.first l)
        end (M.last l)]
    (core.assoc start :prev end)
    (core.assoc end :next start)
    l))

M
