-- [nfnl] fnl/conjure-benchmark/bencode.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local core = require("conjure.nfnl.core")
local bencode = require("conjure.remote.transport.bencode")
local M = define("conjure-benchmark.bencode")
M.name = "bencode"
local function range(n)
  local acc = {}
  for i = 1, n do
    table.insert(acc, i)
  end
  return acc
end
local function _2_()
  local bs = bencode.new()
  return bencode["decode-all"](bs, bencode.encode(bs, {foo = "bar", baz = {1, 2, 3}}))
end
local function _3_()
  local bs = bencode.new()
  local function _4_()
    return {foo = "bar", baz = {1, 2, 3}, quux = {hello = "world"}}
  end
  return bencode["decode-all"](bs, bencode.encode(bs, core.map(_4_, range(500))))
end
M.tasks = {{name = "simple encode and decode", ["task-fn"] = _2_}, {name = "big encode decode", ["task-fn"] = _3_}}
return M
