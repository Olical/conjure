(set package.path
     (.. (vim.fn.getcwd)
         "/lua/?.lua;"
         (vim.fn.getcwd)
         "/lua/?/init.lua;"
         package.path))

(local core (require :conjure.nfnl.core))

(fn benchmark-task [{: name : task-fn}]
  (print "##" name))

(fn benchmark-tasks [{: name : tasks}]
  (print "#" name)
  (core.run! benchmark-task tasks))

(local bencode-bm (require "conjure-benchmark.bencode"))
(benchmark-tasks bencode-bm)
