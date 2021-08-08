local _2afile_2a = "fnl/aniseed/autoload.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.autoload"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.autoload"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local autoload0
do
  local v_23_auto
  do
    local v_25_auto
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
      local function _9_(t, ...)
        return ensure()(...)
      end
      local function _10_(t, k)
        return ensure()[k]
      end
      local function _11_(t, k, v)
        ensure()[k] = v
        return nil
      end
      return setmetatable(res, {__call = _9_, __index = _10_, __newindex = _11_})
    end
    v_25_auto = autoload1
    _1_["autoload"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["autoload"] = v_23_auto
  autoload0 = v_23_auto
end
return nil
