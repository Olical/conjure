local _0_0 = nil
do
  local name_23_0_ = "conjure.main"
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
  _0_0["aniseed/local-fns"] = {require = {config = "conjure.config", config2 = "conjure.config2", mapping = "conjure.mapping"}}
  return {require("conjure.config"), require("conjure.config2"), require("conjure.mapping")}
end
local _2_ = _1_(...)
local config = _2_[1]
local config2 = _2_[2]
local mapping = _2_[3]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local main = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function main0()
      return mapping.init(config.filetypes())
    end
    v_23_0_0 = main0
    _0_0["main"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["main"] = v_23_0_
  main = v_23_0_
end
return nil