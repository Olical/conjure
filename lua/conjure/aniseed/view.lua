local _2afile_2a = "fnl/aniseed/view.fnl"
local _2amodule_name_2a = "conjure.aniseed.view"
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
local fnl = require("conjure.aniseed.fennel")
do end (_2amodule_locals_2a)["fnl"] = fnl
local function serialise(...)
  return fnl.impl().view(...)
end
_2amodule_2a["serialise"] = serialise
return _2amodule_2a
