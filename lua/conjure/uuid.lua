local _0_0 = nil
do
  local name_23_0_ = "conjure.uuid"
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
do local _ = ({nil, _0_0, nil})[2] end
math.randomseed(os.time())
local v4 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function v40()
      local function _3_(_241)
        return string.format("%x", (((_241 == "x") and math.random(0, 15)) or math.random(8, 11)))
      end
      return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", _3_)
    end
    v_23_0_0 = v40
    _0_0["v4"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["v4"] = v_23_0_
  v4 = v_23_0_
end
              -- (v4)
return nil