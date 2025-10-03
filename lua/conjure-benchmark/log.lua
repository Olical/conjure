-- [nfnl] fnl/conjure-benchmark/log.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local log = require("conjure.log")
local vim = _G.vim
local M = define("conjure-benchmark.log")
M.name = "log"
local lines = {"Hello, World! This is a logging call.", "And here's another line.", "And yet another one."}
local function setup()
  log["close-visible"]()
  vim.cmd("edit foo.fnl")
  return log.vsplit()
end
local function _2_()
  log.append(lines)
  return log.flush()
end
local function _3_()
  for _i = 1, 50, 1 do
    log.append(lines)
  end
  return log.flush()
end
M.tasks = {{name = "one logging call at a time", ["before-fn"] = setup, ["task-fn"] = _2_}, {name = "50 log calls in a row", iterations = 100, ["before-fn"] = setup, ["task-fn"] = _3_}}
return M
