-- [nfnl] fnl/conjure-benchmark/bencode.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local M = define("conjure-benchmark.bencode")
M.name = "bencode"
local function _2_()
  return (10 + 20)
end
M.tasks = {{name = "simple encode and decode", ["task-fn"] = _2_}}
return M
