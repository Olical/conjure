local _2afile_2a = "fnl/conjure/main.fnl"
local _2amodule_name_2a = "conjure.main"
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
local config, mapping = autoload("conjure.config"), autoload("conjure.mapping")
do end (_2amodule_locals_2a)["config"] = config
_2amodule_locals_2a["mapping"] = mapping
local function main()
  return mapping.init(config.filetypes())
end
_2amodule_2a["main"] = main
return _2amodule_2a