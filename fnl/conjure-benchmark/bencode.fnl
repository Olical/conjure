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

(set
  M.tasks
  [{:name "simple encode and decode"
    :task-fn
    (fn []
      (let [bs (bencode.new)]
        (bencode.decode-all
          bs
          (bencode.encode
            bs
            {:foo :bar :baz [1 2 3]}))))}
   {:name "big encode decode"
    :task-fn
    (fn []
      (let [bs (bencode.new)]
        (bencode.decode-all
          bs
          (bencode.encode
            bs
            (core.map
              (fn []
                {:foo :bar :baz [1 2 3] :quux {:hello :world}})
              (range 500))))))}])

M
