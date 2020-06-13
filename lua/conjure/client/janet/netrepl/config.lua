local _0_0 = nil
do
  local name_23_0_ = "conjure.client.janet.netrepl.config"
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
  _0_0["aniseed/local-fns"] = {}
  return {}
end
local _2_ = _1_(...)
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local debug_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = false
    _0_0["debug?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["debug?"] = v_23_0_
  debug_3f = v_23_0_
end
local connection = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {["default-host"] = "127.0.0.1", ["default-port"] = "9365"}
    _0_0["connection"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connection"] = v_23_0_
  connection = v_23_0_
end
local mappings = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = {connect = "cc", disconnect = "cd"}
    _0_0["mappings"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["mappings"] = v_23_0_
  mappings = v_23_0_
end
return nil