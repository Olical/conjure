-- [nfnl] Compiled from fnl/conjure/stack.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.stack"
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
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
do local _ = {nil, nil, nil, nil, nil, nil} end
local function push(s, v)
  table.insert(s, v)
  return s
end
_2amodule_2a["push"] = push
do local _ = {push, nil} end
local function pop(s)
  table.remove(s)
  return s
end
_2amodule_2a["pop"] = pop
do local _ = {pop, nil} end
local function peek(s)
  return a.last(s)
end
_2amodule_2a["peek"] = peek
do local _ = {peek, nil} end
return _2amodule_2a
