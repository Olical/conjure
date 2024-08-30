(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local a (require :nfnl.core))
(local bencode (require :conjure.remote.transport.bencode))

(describe "conjure.remote.transport.bencode"
  (fn []
    (describe "basic"
      (fn []
        (let [bs (bencode.new)
              data {:foo [:bar]}]
          (it "data starts empty"
              (fn []
                (assert.are.equals bs.data "")))
          (it "a single bencoded value"
              (fn []
                (assert.same [data] (bencode.decode-all bs (bencode.encode data)))))
          (it "data is empty after a decode"
              (fn []
                (assert.are.equals bs.data ""))))))

    (describe "multiple-values"
      (fn []
        (let [bs (bencode.new)
              data-a {:foo [:bar]}
              data-b [1 2 3]]
        (it "data starts empty"
          (fn []
            (assert.are.equals bs.data "")))
        (it "two bencoded values"
          (fn []
            (assert.same [data-a data-b]
                   (bencode.decode-all
                     bs
                     (.. (bencode.encode data-a)
                         (bencode.encode data-b))))))
        (it "data is empty after a decode"
          (fn []
            (assert.are.equals bs.data ""))))))

    (describe "partial-values"
      (fn []
        (let [bs (bencode.new)
              data-a {:foo [:bar]}
              data-b [1 2 3]
              encoded-b (bencode.encode data-b)]
          (it "data starts empty"
              (fn []
                (assert.are.equals bs.data "")))
          (it "first value"
              (fn []
                (assert.same [data-a]
                             (bencode.decode-all
                               bs
                               (.. (bencode.encode data-a)
                                   (string.sub encoded-b 1 3))))))
          (it "after first, data contains partial data-b"
              (fn []
                (assert.are.equals "li1" bs.data)))
          (it "second value after rest of data"
              (fn []
                (assert.same [data-b]
                             (bencode.decode-all
                               bs
                               (string.sub encoded-b 4)))))
          (it "data is empty after a decode"
              (fn []
                (assert.are.equals bs.data ""))))))))
