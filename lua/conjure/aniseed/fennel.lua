local _2afile_2a = "fnl/aniseed/fennel.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.fennel"
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
    return {autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local fs = _local_4_[1]
local nvim = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.fennel"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local sync_rtp
do
  local v_23_auto
  do
    local v_25_auto
    local function sync_rtp0(compiler)
      local sep = fs["path-sep"]
      local fnl_suffix = (sep .. "fnl" .. sep .. "?.fnl")
      local rtp = nvim.o.runtimepath
      local fnl_path = (rtp:gsub(",", (fnl_suffix .. ";")) .. fnl_suffix)
      local lua_path = fnl_path:gsub((sep .. "fnl" .. sep), (sep .. "lua" .. sep))
      local full_path = (fnl_path .. ";" .. lua_path)
      do end (compiler)["path"] = full_path
      compiler["macro-path"] = full_path
      return nil
    end
    v_25_auto = sync_rtp0
    _1_["sync-rtp"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["sync-rtp"] = v_23_auto
  sync_rtp = v_23_auto
end
local state
do
  local v_23_auto = {["compiler-loaded?"] = false}
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local impl
do
  local v_23_auto
  do
    local v_25_auto
    local function impl0()
      local compiler = require("conjure.aniseed.deps.fennel")
      if not state["compiler-loaded?"] then
        state["compiler-loaded?"] = true
        sync_rtp(compiler)
      end
      return compiler
    end
    v_25_auto = impl0
    _1_["impl"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["impl"] = v_23_auto
  impl = v_23_auto
end
local add_path
do
  local v_23_auto
  do
    local v_25_auto
    local function add_path0(path)
      local fnl = impl()
      do end (fnl)["path"] = (fnl.path .. ";" .. path)
      return nil
    end
    v_25_auto = add_path0
    _1_["add-path"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["add-path"] = v_23_auto
  add_path = v_23_auto
end
return nil
