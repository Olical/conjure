-- [nfnl] Compiled from fnl/conjure/bridge.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.bridge"
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
do local _ = {nil, nil, nil} end
local function viml__3elua(m, f, opts)
  return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
end
_2amodule_2a["viml->lua"] = viml__3elua
do local _ = {viml__3elua, nil} end
return _2amodule_2a
