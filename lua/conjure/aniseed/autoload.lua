local _2afile_2a = "fnl/aniseed/autoload.fnl"
local _0_0
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
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.autoload"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local autoload0
do
  local v_0_
  do
    local v_0_0
    local function autoload1(name)
      local function _2_(t, k)
        return require(name)[k]
      end
      local function _3_(t, k, v)
        require(name)[k] = v
        return nil
      end
      return setmetatable({["aniseed/autoload?"] = true}, {__index = _2_, __newindex = _3_})
    end
    v_0_0 = autoload1
    _0_0["autoload"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["autoload"] = v_0_
  autoload0 = v_0_
end
return nil
