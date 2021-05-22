local _2afile_2a = "fnl/aniseed/fennel.fnl"
local _0_
do
  local name_0_ = "conjure.aniseed.fennel"
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
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local nvim = _local_0_[1]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.aniseed.fennel"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local sync_rtp
do
  local v_0_
  do
    local v_0_0
    local function sync_rtp0(compiler)
      local fnl_suffix = "/fnl/?.fnl"
      local rtp = nvim.o.runtimepath
      local fnl_path = (rtp:gsub(",", (fnl_suffix .. ";")) .. fnl_suffix)
      local lua_path = fnl_path:gsub("/fnl/", "/lua/")
      compiler["path"] = (fnl_path .. ";" .. lua_path)
      return nil
    end
    v_0_0 = sync_rtp0
    _0_["sync-rtp"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["sync-rtp"] = v_0_
  sync_rtp = v_0_
end
local state
do
  local v_0_ = {["compiler-loaded?"] = false}
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["state"] = v_0_
  state = v_0_
end
local impl
do
  local v_0_
  do
    local v_0_0
    local function impl0()
      local compiler = require("conjure.aniseed.deps.fennel")
      if not state["compiler-loaded?"] then
        state["compiler-loaded?"] = true
        sync_rtp(compiler)
      end
      return compiler
    end
    v_0_0 = impl0
    _0_["impl"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["impl"] = v_0_
  impl = v_0_
end
local add_path
do
  local v_0_
  do
    local v_0_0
    local function add_path0(path)
      local fnl = impl()
      fnl["path"] = (fnl.path .. ";" .. path)
      return nil
    end
    v_0_0 = add_path0
    _0_["add-path"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["add-path"] = v_0_
  add_path = v_0_
end
return nil
