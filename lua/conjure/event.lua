local _2afile_2a = "fnl/conjure/event.fnl"
local _1_
do
  local name_4_auto = "conjure.event"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local nvim = _local_4_[3]
local str = _local_4_[4]
local text = _local_4_[5]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.event"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local emit
do
  local v_23_auto
  do
    local v_25_auto
    local function emit0(...)
      do
        local names = a.map(text["upper-first"], {...})
        local function _8_()
          while not a["empty?"](names) do
            nvim.ex.doautocmd("User", ("Conjure" .. str.join(names)))
            table.remove(names)
          end
          return nil
        end
        client.schedule(_8_)
      end
      return nil
    end
    v_25_auto = emit0
    _1_["emit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["emit"] = v_23_auto
  emit = v_23_auto
end
return nil