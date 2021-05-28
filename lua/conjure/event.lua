local _2afile_2a = "fnl/conjure/event.fnl"
local _0_
do
  local name_0_ = "conjure.event"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local client = _local_0_[2]
local nvim = _local_0_[3]
local str = _local_0_[4]
local text = _local_0_[5]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.event"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local emit
do
  local v_0_
  do
    local v_0_0
    local function emit0(...)
      do
        local names = a.map(text["upper-first"], {...})
        local function _2_()
          while not a["empty?"](names) do
            nvim.ex.doautocmd("User", ("Conjure" .. str.join(names)))
            table.remove(names)
          end
          return nil
        end
        client.schedule(_2_)
      end
      return nil
    end
    v_0_0 = emit0
    _0_["emit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["emit"] = v_0_
  emit = v_0_
end
return nil