(local {: define} (require :conjure.nfnl.module))

(local M (define :conjure-benchmark.bencode))

(set M.name "bencode")

(set
  M.tasks
  [{:name "simple encode and decode"
    :task-fn
    (fn []
      (+ 10 20))}])

M
