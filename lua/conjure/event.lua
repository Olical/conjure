local _0_0 = nil
do
  local name_0_ = "conjure.event"
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
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local client = _1_[2]
local nvim = _1_[3]
local str = _1_[4]
local text = _1_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.event"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local emit = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function emit0(...)
      do
        local names = a.map(text["upper-first"], {...})
        local function _3_()
          while not a["empty?"](names) do
            nvim.ex.doautocmd("User", ("Conjure" .. str.join(names)))
            table.remove(names)
          end
          return nil
        end
        client.schedule(_3_)
      end
      return nil
    end
    v_0_0 = emit0
    _0_0["emit"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["emit"] = v_0_
  emit = v_0_
end
return nil