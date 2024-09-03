-- [nfnl] Compiled from fnl/conjure/remote/transport/swank.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local log = autoload("conjure.log")
local function encode(msg)
  local n = a.count(msg)
  local header = string.format("%06x", (1 + n))
  return (header .. msg .. "\n")
end
local function decode(msg)
  local len = tonumber(string.sub(msg, 1, 7), 16)
  local cmd = string.sub(msg, 7, len)
  return cmd
end
return {encode = encode, decode = decode}
