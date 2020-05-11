local _0_0 = nil
do
  local name_23_0_ = "conjure.fs"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
do local _ = ({nil, _0_0, nil})[2] end
local config_dir = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function config_dir0()
      return ((nvim.fn.getenv("XDG_CONFIG_HOME") or (nvim.fn.getenv("HOME") .. "/.config")) .. "/conjure")
    end
    v_23_0_0 = config_dir0
    _0_0["config-dir"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config-dir"] = v_23_0_
  config_dir = v_23_0_
end
local findfile = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function findfile0(name, path)
      local res = nvim.fn.findfile(name, path)
      if not a["empty?"](res) then
        return res
      end
    end
    v_23_0_0 = findfile0
    _0_0["findfile"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["findfile"] = v_23_0_
  findfile = v_23_0_
end
local resolve = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function resolve0(name)
      return (findfile(name, ".;") or findfile(name, (config_dir() .. ";")))
    end
    v_23_0_0 = resolve0
    _0_0["resolve"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["resolve"] = v_23_0_
  resolve = v_23_0_
end
return nil