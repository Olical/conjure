-- [nfnl] Compiled from fnl/conjure/bridge.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.bridge"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local viml__3elua = (_2amodule_2a)["viml->lua"]
do local _ = {nil, nil, nil, nil} end
local function viml__3elua0(m, f, opts)
  return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
end
_2amodule_2a["viml->lua"] = viml__3elua0
do local _ = {viml__3elua0, nil} end
return _2amodule_2a
