(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local ll (require :conjure.linked-list))

(describe "conjure.linked-list"
  (fn []

    (describe "basics"
      (fn []
        (let [l (ll.create [1 2 3])]
          (it "get first value"
              (fn []
                (assert.are.equals 1 (->> l (ll.val)))))
          (it "get second value"
              (fn []
                (assert.are.equals 2 (->> l (ll.next) (ll.val)))))
          (it "forward and back"
              (fn []
                (assert.are.equals 1 (->> l (ll.next) (ll.prev) (ll.val)))))
          (it "last by steps"
              (fn []
                (assert.are.equals 3 (->> l (ll.next) (ll.next) (ll.val)))))
          (it "off the end"
              (fn []
                (assert.are.equals nil (->> l (ll.next) (ll.next) (ll.next)))))
          (it "off the front"
              (fn []
                (assert.are.equals nil (->> l (ll.prev)))))
          (it "val handles nils"
              (fn []
                (assert.are.equals nil (ll.val nil))))
          (it "last"
              (fn []
                (assert.are.equals 3 (->> l (ll.last) (ll.val)))))
          (it "first"
              (fn []
                (assert.are.equals 1 (->> l (ll.first) (ll.val)))))
          (it "last then first"
              (fn []
                (assert.are.equals 1 (->> l (ll.last) (ll.first) (ll.val))))))))

    (describe "until"
      (fn []
        (let [l (ll.create [1 2 3 4 5])]

          (it "nil if not found"
              (fn []
                (assert.are.equals nil (->> l (ll.until #(= 8 (ll.val $1))) (ll.val)))))
          (it "target node if found"
              (fn []
                (assert.are.equals 3 (->> l (ll.until #(= 3 (ll.val $1))) (ll.val)))))
          (it "can find the one before"
              (fn []
                (assert.are.equals 2 (->> l (ll.until #(= 3 (->> $1 (ll.next) (ll.val)))) (ll.val))))))))

    (describe "cycle"
      (fn []
        (let [l (ll.cycle (ll.create [1 2 3]))]
          (it "first is still first"
              (fn []
                (assert.are.equals 1 (->> l (ll.val)))))
          (it "can still next"
              (fn []
                (assert.are.equals 2 (->> l (ll.next) (ll.val)))))
          (it "can still next next (last)"
              (fn []
                (assert.are.equals 3 (->> l (ll.next) (ll.next) (ll.val)))))
          (it "off the end loops"
              (fn []
                (assert.are.equals 1 (->> l (ll.next) (ll.next) (ll.next) (ll.val)))))
          (it "off the front loops"
              (fn []
                (assert.are.equals 3 (->> l (ll.prev) (ll.val))))))))))

