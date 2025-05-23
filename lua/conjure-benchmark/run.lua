-- [nfnl] fnl/conjure-benchmark/run.fnl
package.path = (vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path)
local core = require("conjure.nfnl.core")
local iterations = 10000
local function benchmark_task(_1_)
  local name = _1_["name"]
  local task_fn = _1_["task-fn"]
  local start = vim.uv.now()
  for _i = 1, iterations do
    task_fn()
  end
  vim.uv.update_time()
  local duration = ((vim.uv.now() - start) / iterations)
  return print("##", name, ("[" .. duration .. "ms]"))
end
local function benchmark_tasks(_2_)
  local name = _2_["name"]
  local tasks = _2_["tasks"]
  print("Iterations:", iterations)
  print("#", name)
  return core["run!"](benchmark_task, tasks)
end
local bencode_bm = require("conjure-benchmark.bencode")
return benchmark_tasks(bencode_bm)
