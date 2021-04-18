local _0_0
do
  local module_0_ = require("conjure.aniseed.deps.fennel")
  package.loaded["conjure.aniseed.fennel"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.deps.fennel"), require("conjure.aniseed.nvim")}
local fennel = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.fennel"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local add_path
do
  local v_0_
  local function add_path0(path)
    fennel.path = (fennel.path .. ";" .. path)
    return nil
  end
  v_0_ = add_path0
  _0_0["add-path"] = v_0_
  add_path = v_0_
end
local sync_rtp
do
  local v_0_
  local function sync_rtp0()
    local fnl_suffix = "/fnl/?.fnl"
    local rtp = nvim.o.runtimepath
    local fnl_path = (rtp:gsub(",", (fnl_suffix .. ";")) .. fnl_suffix)
    local lua_path = fnl_path:gsub("/fnl/", "/lua/")
    fennel["path"] = (fnl_path .. ";" .. lua_path)
    return nil
  end
  v_0_ = sync_rtp0
  _0_0["sync-rtp"] = v_0_
  sync_rtp = v_0_
end
return sync_rtp()
