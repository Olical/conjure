-- [nfnl] Compiled from fnl/conjure/main.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.main"
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
local config, mapping = autoload("conjure.config"), autoload("conjure.mapping")
do
end
(_2amodule_locals_2a)["config"] = config
_2amodule_locals_2a["mapping"] = mapping
do
  local _ = { nil, nil, nil, nil, nil, nil, nil }
end
local function main()
  return mapping.init(config.filetypes())
end
_2amodule_2a["main"] = main
do
  local _ = { main, nil }
end
return _2amodule_2a
