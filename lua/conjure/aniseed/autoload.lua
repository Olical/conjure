local _2afile_2a = "fnl/aniseed/autoload.fnl"
local _0_
do
  local name_0_ = "conjure.aniseed.autoload"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.aniseed.autoload"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local autoload0
do
  local v_0_
  do
    local v_0_0
    local function autoload1(name)
      local res = {["aniseed/autoload-enabled?"] = true, ["aniseed/autoload-module"] = false}
      local function ensure()
        if res["aniseed/autoload-module"] then
          return res["aniseed/autoload-module"]
        else
          local m = require(name)
          do end (res)["aniseed/autoload-module"] = m
          return m
        end
      end
      local function _2_(t, k)
        return ensure()[k]
      end
      local function _3_(t, k, v)
        ensure()[k] = v
        return nil
      end
      return setmetatable(res, {__index = _2_, __newindex = _3_})
    end
    v_0_0 = autoload1
    _0_["autoload"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["autoload"] = v_0_
  autoload0 = v_0_
end
return nil
