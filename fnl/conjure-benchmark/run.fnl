(set package.path
     (.. (vim.fn.getcwd)
         "/lua/?.lua;"
         (vim.fn.getcwd)
         "/lua/?/init.lua;"
         package.path))

(local core (require :conjure.nfnl.core))
(local default-iterations 1000)

(fn benchmark-task [{: name : task-fn : iterations}]
  (let [start (vim.uv.now)
        iterations (or iterations default-iterations)]
    (for [_i 1 iterations]
      (task-fn))
    (vim.uv.update_time)
    (let [duration (/ (- (vim.uv.now) start) iterations)]
      (print "##" name (.. "x" iterations) (.. "[" duration "ms]")))))

(fn benchmark-tasks [{: name : tasks}]
  (print "#" name)
  (core.run! benchmark-task tasks))

(benchmark-tasks (require "conjure-benchmark.bencode"))
(benchmark-tasks (require "conjure-benchmark.log"))
