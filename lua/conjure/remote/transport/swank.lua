-- [nfnl] fnl/conjure/remote/transport/swank.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local M = define("conjure.remote.transport.swank")
M.encode = function(msg)
  local n = core.count(msg)
  local header = string.format("%06x", (1 + n))
  return (header .. msg .. "\n")
end
M.decode = function(msg)
  local len = tonumber(string.sub(msg, 1, 7), 16)
  local cmd = string.sub(msg, 7, len)
  return cmd
end
return M
