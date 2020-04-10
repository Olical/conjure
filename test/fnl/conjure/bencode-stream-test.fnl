(module bencode-stream-test
  {require {bencode-stream conjure.bencode-stream
            bencode conjure.bencode}})

(deftest basic
  (let [bs (bencode-stream.new)
        data {:foo [:bar]}]
    (t.= bs.data "" "data starts empty")
    (t.pr= [data]
           (bencode-stream.decode-all bs (bencode.encode data))
           "a single bencoded value")
    (t.= bs.data "" "data is empty after a decode")))

(deftest multiple-values
  (let [bs (bencode-stream.new)
        data-a {:foo [:bar]}
        data-b [1 2 3]]
    (t.= bs.data "" "data starts empty")
    (t.pr= [data-a data-b]
           (bencode-stream.decode-all
             bs
             (.. (bencode.encode data-a)
                 (bencode.encode data-b)))
           "two bencoded values")
    (t.= bs.data "" "data is empty after a decode")))

(deftest partial-values
  (let [bs (bencode-stream.new)
        data-a {:foo [:bar]}
        data-b [1 2 3]
        encoded-b (bencode.encode data-b)]
    (t.= bs.data "" "data starts empty")
    (t.pr= [data-a]
           (bencode-stream.decode-all
             bs
             (.. (bencode.encode data-a)
                 (string.sub encoded-b 1 3)))
           "first value")
    (t.= "li1" bs.data "after first, data contains partial data-b")
    (t.pr= [data-b]
           (bencode-stream.decode-all
             bs
             (string.sub encoded-b 4))
           "second value after rest of data")
    (t.= bs.data "" "data is empty after a decode")))
