(set package.path
     (.. (vim.fn.getcwd)
         "/lua/?.lua;"
         (vim.fn.getcwd)
         "/lua/?/init.lua;"
         package.path))

(local core (require :conjure.nfnl.core))
(local iterations 10000)

(fn benchmark-task [{: name : task-fn}]
  (let [start (vim.uv.now)]
    (for [i 1 iterations]
      (task-fn))
    (vim.uv.update_time)
    (let [duration (/ (- (vim.uv.now) start) iterations)]
      (print "##" name (.. "[" duration "ms]")))))

(fn benchmark-tasks [{: name : tasks}]
  (print "Iterations:" iterations)
  (print "#" name)
  (core.run! benchmark-task tasks))

(local bencode-bm (require "conjure-benchmark.bencode"))
(benchmark-tasks bencode-bm)
