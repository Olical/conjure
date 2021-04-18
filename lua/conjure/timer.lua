local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.timer"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.timer"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local defer
do
  local v_0_
  local function defer0(f, ms)
    local t = vim.loop.new_timer()
    t:start(ms, 0, vim.schedule_wrap(f))
    return t
  end
  v_0_ = defer0
  _0_0["defer"] = v_0_
  defer = v_0_
end
local destroy
do
  local v_0_
  local function destroy0(t)
    if t then
      t:stop()
      t:close()
    end
    return nil
  end
  v_0_ = destroy0
  _0_0["destroy"] = v_0_
  destroy = v_0_
end
return nil