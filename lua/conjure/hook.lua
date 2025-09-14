-- [nfnl] fnl/conjure/hook.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.hook")
M["hook-fns"] = (M["hook-fns"] or {})
M["hook-override-fns"] = (M["hook-override-fns"] or {})
M.define = function(name, f)
  return core.assoc(M["hook-fns"], name, f)
end
M.override = function(name, f)
  return core.assoc(M["hook-override-fns"], name, f)
end
M.get = function(name)
  return core.get(M["hook-fns"], name)
end
M.exec = function(name, ...)
  local f = (core.get(M["hook-override-fns"], name) or core.get(M["hook-fns"], name))
  if f then
    return f(...)
  else
    return error(str.join(" ", {"conjure.hook: Hook not found, can not exec", name}))
  end
end
return M
