-- [nfnl] fnl/conjure/stack.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local M = define("conjure.stack")
M.push = function(s, v)
  table.insert(s, v)
  return s
end
M.pop = function(s)
  table.remove(s)
  return s
end
M.peek = function(s)
  return core.last(s)
end
return M
