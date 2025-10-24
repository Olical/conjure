-- [nfnl] fnl/nfnl/header.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.nfnl.header")
local tag = "[nfnl]"
M["with-header"] = function(file, src)
  return ("-- " .. tag .. " " .. file .. "\n" .. src)
end
M["tagged?"] = function(s)
  if s then
    return core["number?"](s:find(tag, 1, true))
  else
    return nil
  end
end
M["source-path"] = function(s)
  if M["tagged?"](s) then
    local function _3_(part)
      return (str["ends-with?"](part, ".fnl") and part)
    end
    return core.some(_3_, str.split(s, "%s+"))
  else
    return nil
  end
end
return M
