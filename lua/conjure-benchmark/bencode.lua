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
local function split_into_chunks(str, chunk_size)
  local len = string.len(str)
  local chunks = {}
  for i = 1, len, chunk_size do
    local _end = math.min((i + (chunk_size - 1)), len)
    table.insert(chunks, string.sub(str, i, _end))
  end
  return chunks
end
local function _2_()
  local bs = bencode.new()
  return bencode["decode-all"](bs, bencode.encode({foo = "bar", baz = {1, 2, 3}}))
end
local function _3_()
  local bs = bencode.new()
  local data
  local function _4_()
    return {foo = "bar", baz = {1, 2, 3}, quux = {hello = "world"}}
  end
  data = bencode.encode(core.map(_4_, range(500)))
  local function _5_(chunk)
    return bencode["decode-all"](bs, chunk)
  end
  return core["run!"](_5_, split_into_chunks(data, 512))
end
M.tasks = {{name = "simple encode and decode", ["task-fn"] = _2_}, {name = "big encode, chunked decode", ["task-fn"] = _3_}}
return M
