-- [nfnl] Compiled from fnl/conjure/hook.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.hook"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["str"] = str
do local _ = {nil, nil, nil, nil, nil, nil, nil} end
local hook_fns = ((_2amodule_2a)["hook-fns"] or {})
do end (_2amodule_2a)["hook-fns"] = hook_fns
do local _ = {nil, nil} end
local hook_override_fns = ((_2amodule_2a)["hook-override-fns"] or {})
do end (_2amodule_2a)["hook-override-fns"] = hook_override_fns
do local _ = {nil, nil} end
local function define(name, f)
  return a.assoc(hook_fns, name, f)
end
_2amodule_2a["define"] = define
do local _ = {define, nil} end
local function override(name, f)
  return a.assoc(hook_override_fns, name, f)
end
_2amodule_2a["override"] = override
do local _ = {override, nil} end
local function get(name)
  return a.get(hook_fns, name)
end
_2amodule_2a["get"] = get
do local _ = {get, nil} end
local function exec(name, ...)
  local f = (a.get(hook_override_fns, name) or a.get(hook_fns, name))
  if f then
    return f(...)
  else
    return error(str.join(" ", {"conjure.hook: Hook not found, can not exec", name}))
  end
end
_2amodule_2a["exec"] = exec
do local _ = {exec, nil} end
return _2amodule_2a
