local _2afile_2a = "fnl/conjure/stack.fnl"
local _2amodule_name_2a = "conjure.stack"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
local function push(s, v)
  table.insert(s, v)
  return s
end
_2amodule_2a["push"] = push
local function pop(s)
  table.remove(s)
  return s
end
_2amodule_2a["pop"] = pop
local function peek(s)
  return a.last(s)
end
_2amodule_2a["peek"] = peek
return _2amodule_2a