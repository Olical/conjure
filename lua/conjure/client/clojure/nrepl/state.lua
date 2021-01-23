local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl.state"
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
    return {require("conjure.client")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {client = "conjure.client"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local client = _1_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.state"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local get = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function _3_()
      return {["join-next"] = {key = nil}, conn = nil}
    end
    v_0_0 = (_0_0.get or client["new-state"](_3_))
    _0_0["get"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get"] = v_0_
  get = v_0_
end
return nil