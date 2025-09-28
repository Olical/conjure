-- [nfnl] fnl/conjure-benchmark/run.fnl
package.path = (vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path)
local core = require("conjure.nfnl.core")
local default_iterations = 1000
local function benchmark_task(_1_)
  local name = _1_["name"]
  local task_fn = _1_["task-fn"]
  local iterations = _1_["iterations"]
  local start = vim.uv.now()
  local iterations0 = (iterations or default_iterations)
  for _i = 1, iterations0 do
    task_fn()
  end
  vim.uv.update_time()
  local duration = ((vim.uv.now() - start) / iterations0)
  return print("##", name, ("x" .. iterations0), ("[" .. duration .. "ms]"))
end
local function benchmark_tasks(_2_)
  local name = _2_["name"]
  local tasks = _2_["tasks"]
  print("#", name)
  return core["run!"](benchmark_task, tasks)
end
benchmark_tasks(require("conjure-benchmark.bencode"))
return benchmark_tasks(require("conjure-benchmark.log"))
