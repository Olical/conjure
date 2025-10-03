(local {: define} (require :conjure.nfnl.module))
(local log (require :conjure.log))
(local vim _G.vim)

(local M (define :conjure-benchmark.log))

(set M.name "log")

(local lines
  ["Hello, World! This is a logging call."
   "And here's another line."
   "And yet another one."])

(fn setup []
  (log.close-visible)
  (vim.cmd "edit foo.fnl")
  (log.vsplit))

(set
  M.tasks
  [{:name "one logging call at a time"
    :before-fn setup
    :task-fn
    (fn []
      (log.append lines)
      (log.flush))}

   {:name "50 log calls in a row"
    :iterations 100
    :before-fn setup
    :task-fn
    (fn []
      (for [_i 1 50 1]
        (log.append lines))
      (log.flush))}])

M
