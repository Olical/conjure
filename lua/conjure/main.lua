-- [nfnl] Compiled from fnl/conjure/main.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.main"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local config, mapping = autoload("conjure.config"), autoload("conjure.mapping")
do end (_2amodule_locals_2a)["config"] = config
_2amodule_locals_2a["mapping"] = mapping
local main = (_2amodule_2a).main
local config0 = (_2amodule_locals_2a).config
local mapping0 = (_2amodule_locals_2a).mapping
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function main0()
  return mapping0.init(config0.filetypes())
end
_2amodule_2a["main"] = main0
do local _ = {main0, nil} end
return _2amodule_2a
