-- [nfnl] Compiled from fnl/conjure/hook.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.hook"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["str"] = str
local define = (_2amodule_2a).define
local exec = (_2amodule_2a).exec
local get = (_2amodule_2a).get
local hook_fns = (_2amodule_2a)["hook-fns"]
local hook_override_fns = (_2amodule_2a)["hook-override-fns"]
local override = (_2amodule_2a).override
local a0 = (_2amodule_locals_2a).a
local str0 = (_2amodule_locals_2a).str
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local hook_fns0 = ((_2amodule_2a)["hook-fns"] or {})
do end (_2amodule_2a)["hook-fns"] = hook_fns0
do local _ = {nil, nil} end
local hook_override_fns0 = ((_2amodule_2a)["hook-override-fns"] or {})
do end (_2amodule_2a)["hook-override-fns"] = hook_override_fns0
do local _ = {nil, nil} end
local function define0(name, f)
  return a0.assoc(hook_fns0, name, f)
end
_2amodule_2a["define"] = define0
do local _ = {define0, nil} end
local function override0(name, f)
  return a0.assoc(hook_override_fns0, name, f)
end
_2amodule_2a["override"] = override0
do local _ = {override0, nil} end
local function get0(name)
  return a0.get(hook_fns0, name)
end
_2amodule_2a["get"] = get0
do local _ = {get0, nil} end
local function exec0(name, ...)
  local f = (a0.get(hook_override_fns0, name) or a0.get(hook_fns0, name))
  if f then
    return f(...)
  else
    return error(str0.join(" ", {"conjure.hook: Hook not found, can not exec", name}))
  end
end
_2amodule_2a["exec"] = exec0
do local _ = {exec0, nil} end
return _2amodule_2a
