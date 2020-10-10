local _0_0 = nil
do
  local name_0_ = "conjure.bridge"
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
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.bridge"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local viml__3elua = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function viml__3elua0(m, f, opts)
      return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
    end
    v_0_0 = viml__3elua0
    _0_0["viml->lua"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["viml->lua"] = v_0_
  viml__3elua = v_0_
end
return nil