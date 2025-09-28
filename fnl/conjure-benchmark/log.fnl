(local {: define} (require :conjure.nfnl.module))
(local core (require :conjure.nfnl.core))
(local log (require :conjure.log))

(local M (define :conjure-benchmark.log))

(set M.name "log")

(local lines
  ["Hello, World! This is a logging call."
   "And here's another line."
   "And yet another one."])

(set
  M.tasks
  [{:name "one logging call at a time"
    :task-fn #(log.append lines)}
   {:name "30 log calls in a row"
    :iterations 100
    :task-fn (fn []
               (for [_i 1 30 1]
                 (log.append lines)))}])

M
