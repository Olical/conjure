(module conjure.linked-list-test
  {require {ll conjure.linked-list}})

(deftest basics
  (let [l (ll.create [1 2 3])]
    (t.= 1 (->> l (ll.val)) "get first value")
    (t.= 2 (->> l (ll.next) (ll.val)) "get second value")
    (t.= 1 (->> l (ll.next) (ll.prev) (ll.val)) "forward and back")
    (t.= 3 (->> l (ll.next) (ll.next) (ll.val)) "last by steps")
    (t.= nil (->> l (ll.next) (ll.next) (ll.next)) "off the end")
    (t.= nil (->> l (ll.prev)) "off the front")
    (t.= nil (ll.val nil) "val handles nils")
    (t.= 3 (->> l (ll.last) (ll.val)) "last")
    (t.= 1 (->> l (ll.first) (ll.val)) "first")
    (t.= 1 (->> l (ll.last) (ll.first) (ll.val)) "last then first")))

(deftest until
  (let [l (ll.create [1 2 3 4 5])]
    (t.= nil (->> l (ll.until #(= 8 (ll.val $1))) (ll.val)) "nil if not found")
    (t.= 3 (->> l (ll.until #(= 3 (ll.val $1))) (ll.val)) "target node if found")
    (t.= 2 (->> l (ll.until #(= 3 (->> $1 (ll.next) (ll.val)))) (ll.val))
         "can find the one before")))

(deftest cycle
  (let [l (ll.cycle (ll.create [1 2 3]))]
    (t.= 1 (->> l (ll.val)) "first is still first")
    (t.= 2 (->> l (ll.next) (ll.val)) "can still next")
    (t.= 3 (->> l (ll.next) (ll.next) (ll.val)) "can still next next (last)")
    (t.= 1 (->> l (ll.next) (ll.next) (ll.next) (ll.val)) "off the end loops")
    (t.= 3 (->> l (ll.prev) (ll.val)) "off the front loops")))
