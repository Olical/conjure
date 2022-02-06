local _2afile_2a = "fnl/conjure/bridge.fnl"
local _2amodule_name_2a = "conjure.bridge"
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
local function viml__3elua(m, f, opts)
  return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
end
_2amodule_2a["viml->lua"] = viml__3elua
return _2amodule_2a