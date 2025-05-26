(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local ffi (require :ffi))
(local bencode (require :conjure.remote.transport.bencode))

(fn buffer-content [bs]
  "Get the current buffer content as a string"
  (let [(ptr blen) (bs.buf:ref)]
    (ffi.string ptr blen)))

(fn assert-buffer [bs expected]
  "Assert buffer contains expected content"
  (assert.are.equals expected (buffer-content bs)))

(fn assert-stack-depth [bs expected]
  "Assert stack has expected depth"
  (assert.are.equals expected (length bs.stack)))

(fn assert-stack-empty [bs]
  "Assert stack is empty"
  (assert-stack-depth bs 0))

(describe "conjure.remote.transport.bencode"
  (fn []
    (describe "basic functionality"
      (fn []
        (let [bs (bencode.new)
              data {:foo [:bar]}]
          (it "buffer starts empty"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs)))
          (it "a single bencoded value"
            (fn []
              (assert.same [data] (bencode.decode-all bs (bencode.encode data)))))
          (it "buffer is empty after a decode"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "multiple-values"
      (fn []
        (let [bs (bencode.new)
              data-a {:foo [:bar]}
              data-b [1 2 3]]
          (it "buffer starts empty"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs)))
          (it "two bencoded values"
            (fn []
              (assert.same [data-a data-b]
                (bencode.decode-all bs
                  (.. (bencode.encode data-a)
                      (bencode.encode data-b))))))
          (it "buffer is empty after a decode"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "partial list parsing"
      (fn []
        (let [bs (bencode.new)
              data-a {:foo [:bar]}
              data-b [1 2 3]
              encoded-b (bencode.encode data-b)]
          (it "buffer starts empty"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs)))
          (it "first value with partial list start"
            (fn []
              (assert.same [data-a]
                (bencode.decode-all bs
                  (.. (bencode.encode data-a)
                      (string.sub encoded-b 1 3))))))
          (it "after first, buffer contains partial integer and list is on stack"
            (fn []
              (assert-buffer bs "i1")
              (assert-stack-depth bs 1)
              (assert.are.equals "list" (. bs.stack 1 :t))))
          (it "second value completes the list"
            (fn []
              (assert.same [data-b]
                (bencode.decode-all bs (string.sub encoded-b 4)))))
          (it "buffer is empty after completion"
            (fn []
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "integer edge cases"
      (fn []
        (it "incomplete integer at start"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "i"))
              (assert-buffer bs "i")
              (assert-stack-empty bs))))
        (it "incomplete integer with partial number"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "i123"))
              (assert-buffer bs "i123")
              (assert-stack-empty bs))))
        (it "complete integer after partial"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "i123")
              (assert.same [123] (bencode.decode-all bs "e"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "negative integer split"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "i-"))
              (assert-buffer bs "i-")
              (assert.same [-42] (bencode.decode-all bs "42e"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "string edge cases"
      (fn []
        (it "incomplete string length"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "3"))
              (assert-buffer bs "3")
              (assert-stack-empty bs))))
        (it "incomplete string with colon but no content"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "3:"))
              (assert-buffer bs "3:")
              (assert-stack-empty bs))))
        (it "incomplete string with partial content"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "3:fo"))
              (assert-buffer bs "3:fo")
              (assert-stack-empty bs))))
        (it "complete string after partial"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "3:fo")
              (assert.same ["foo"] (bencode.decode-all bs "o"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "zero-length string"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [""] (bencode.decode-all bs "0:"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "multi-digit length split across chunks"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "1"))
              (assert.same [] (bencode.decode-all bs "0"))
              (assert.same [] (bencode.decode-all bs ":"))
              (assert.same [] (bencode.decode-all bs "hello"))
              (assert.same ["helloworld"] (bencode.decode-all bs "world"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "list edge cases"
      (fn []
        (it "empty list"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [[]] (bencode.decode-all bs "le"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "list start only"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "l"))
              (assert-buffer bs "")
              (assert-stack-depth bs 1)
              (assert.are.equals "list" (. bs.stack 1 :t)))))
        (it "nested list start"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "ll"))
              (assert-buffer bs "")
              (assert-stack-depth bs 2)
              (assert.are.equals "list" (. bs.stack 1 :t))
              (assert.are.equals "list" (. bs.stack 2 :t)))))
        (it "complete nested empty lists"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "ll")
              (assert.same [[[]]] (bencode.decode-all bs "ee"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "list with mixed incomplete elements"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "li42"))
              (assert-buffer bs "i42")
              (assert-stack-depth bs 1)
              (bencode.decode-all bs "e3:fo")
              (assert-buffer bs "3:fo")
              (assert.same [[42 "foo"]] (bencode.decode-all bs "oe"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))))

    (describe "dict edge cases"
      (fn []
        (it "empty dict"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [{}] (bencode.decode-all bs "de"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "dict start only"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "d"))
              (assert-buffer bs "")
              (assert-stack-depth bs 1)
              (assert.are.equals "dict" (. bs.stack 1 :t)))))
        (it "dict with incomplete key"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "d3:fo"))
              (assert-buffer bs "3:fo")
              (assert-stack-depth bs 1))))
        (it "dict with complete key but no value"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "d3:fo")
              (assert.same [] (bencode.decode-all bs "o"))
              (assert-buffer bs "")
              (assert-stack-depth bs 1)
              (assert.are.equals "foo" (. bs.stack 1 :k)))))
        (it "dict with incomplete value"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "d3:foo")
              (assert.same [] (bencode.decode-all bs "i4"))
              (assert-buffer bs "i4")
              (assert-stack-depth bs 1)
              (assert.are.equals "foo" (. bs.stack 1 :k)))))
        (it "complete dict after partial parsing"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "d3:fooi4")
              (assert.same [{:foo 42}] (bencode.decode-all bs "2ee"))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "nested dict in list"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [] (bencode.decode-all bs "ld"))
              (assert-stack-depth bs 2)
              (assert.are.equals "list" (. bs.stack 1 :t))
              (assert.are.equals "dict" (. bs.stack 2 :t)))))
        (it "list in dict value"
          (fn []
            (let [bs (bencode.new)]
              (bencode.decode-all bs "d3:fool")
              (assert-stack-depth bs 2)
              (assert.are.equals "dict" (. bs.stack 1 :t))
              (assert.are.equals "list" (. bs.stack 2 :t))
              (assert.are.equals "foo" (. bs.stack 1 :k)))))))

    (describe "boundary conditions"
      (fn []
        (it "single character chunks"
          (fn []
            (let [bs (bencode.new)
                  encoded (bencode.encode {:key "value"})]
              (var final-result [])
              (for [i 1 (length encoded)]
                (let [result (bencode.decode-all bs (string.sub encoded i i))]
                  (each [_ v (ipairs result)]
                    (table.insert final-result v))))
              (assert.same [{:key "value"}] final-result)
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "exact boundary splits"
          (fn []
            (let [bs (bencode.new)]
              (assert.same [123] (bencode.decode-all bs "i123e3:"))
              (assert.same ["foo"] (bencode.decode-all bs "foo"))
              (assert.same [] (bencode.decode-all bs ""))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "large nested structure split"
          (fn []
            (let [bs (bencode.new)
                  data {:numbers [1 2 3] :nested {:inner "value"}}
                  encoded (bencode.encode data)
                  mid (math.floor (/ (length encoded) 2))]
              (assert.same [] (bencode.decode-all bs (string.sub encoded 1 mid)))
              (assert.same [data] (bencode.decode-all bs (string.sub encoded (+ mid 1))))
              (assert-buffer bs "")
              (assert-stack-empty bs))))
        (it "very large data structure in 32-char chunks"
          (fn []
            (let [bs (bencode.new)
                  item {:id "item" :data "some-long-data-string-that-takes-space" :nums [1 2 3 4 5]}
                  list []]
              (while (< (length (bencode.encode list)) 100000)
                (table.insert list item))
              (let [encoded (bencode.encode list)
                    chunk-size 32
                    final-result []]
                (for [start 1 (length encoded) chunk-size]
                  (let [end (math.min (+ start chunk-size -1) (length encoded))
                        chunk (string.sub encoded start end)
                        result (bencode.decode-all bs chunk)]
                    (each [_ v (ipairs result)]
                      (table.insert final-result v))))
                (assert.same [list] final-result)
                (assert-buffer bs "")
                (assert-stack-empty bs)))))))))
