-- [nfnl] fnl/conjure-benchmark/run.fnl
package.path = (vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path)
local core = require("conjure.nfnl.core")
local function benchmark_task(_1_)
  local name = _1_["name"]
  local task_fn = _1_["task-fn"]
  return print("##", name)
end
local function benchmark_tasks(_2_)
  local name = _2_["name"]
  local tasks = _2_["tasks"]
  print("#", name)
  return core["run!"](benchmark_task, tasks)
end
local bencode_bm = require("conjure-benchmark.bencode")
return benchmark_tasks(bencode_bm)
