local _2afile_2a = "fnl/conjure/timer.fnl"
local _1_
do
  local name_4_auto = "conjure.timer"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.timer"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local defer
do
  local v_23_auto
  do
    local v_25_auto
    local function defer0(f, ms)
      local t = vim.loop.new_timer()
      t:start(ms, 0, vim.schedule_wrap(f))
      return t
    end
    v_25_auto = defer0
    _1_["defer"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["defer"] = v_23_auto
  defer = v_23_auto
end
local destroy
do
  local v_23_auto
  do
    local v_25_auto
    local function destroy0(t)
      if t then
        t:stop()
        t:close()
      end
      return nil
    end
    v_25_auto = destroy0
    _1_["destroy"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["destroy"] = v_23_auto
  destroy = v_23_auto
end
return nil