local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.view"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.deps.fennelview")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {view = "conjure.aniseed.deps.fennelview"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local view = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.view"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local serialise = nil
do
  local v_0_ = nil
  do
    local v_0_0 = view
    _0_0["serialise"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["serialise"] = v_0_
  serialise = v_0_
end
return nil
