(local {: define} (require :conjure.nfnl.module))
(local core (require :conjure.nfnl.core))
(local bencode (require :conjure.remote.transport.bencode))

(local M (define :conjure-benchmark.bencode))

(set M.name "bencode")

(fn range [n]
  (let [acc []]
    (for [i 1 n]
      (table.insert acc i))
    acc))

(fn split-into-chunks [str chunk-size]
  (let [len (string.len str)
        chunks []]
    (for [i 1 len chunk-size]
      (let [end (math.min (+ i (- chunk-size 1)) len)]
        (table.insert chunks (string.sub str i end))))
    chunks))

(set
  M.tasks
  [{:name "simple encode and decode"
    :task-fn
    (fn []
      (let [bs (bencode.new)]
        (bencode.decode-all
          bs
          (bencode.encode
            {:foo :bar :baz [1 2 3]}))))}
   {:name "big encode, chunked decode"
    :task-fn
    (fn []
      (let [bs (bencode.new)
            data (bencode.encode
                   (core.map
                     (fn []
                       {:foo :bar :baz [1 2 3] :quux {:hello :world}})
                     (range 500)))]
        (core.run!
          (fn [chunk]
            (bencode.decode-all bs chunk))
          (split-into-chunks data 512))))}])

M
