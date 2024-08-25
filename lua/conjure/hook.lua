-- [nfnl] Compiled from fnl/conjure/hook.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local hook_fns = {}
local hook_override_fns = {}
local function define(name, f)
  return a.assoc(hook_fns, name, f)
end
local function override(name, f)
  return a.assoc(hook_override_fns, name, f)
end
local function get(name)
  return a.get(hook_fns, name)
end
local function exec(name, ...)
  local f = (a.get(hook_override_fns, name) or a.get(hook_fns, name))
  if f then
    return f(...)
  else
    return error(str.join(" ", {"conjure.hook: Hook not found, can not exec", name}))
  end
end
return {["hook-fns"] = hook_fns, ["hook-override-fns"] = hook_override_fns, define = define, override = override, get = get, exec = exec}
