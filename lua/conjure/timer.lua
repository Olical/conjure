local _0_0 = nil
do
  local name_23_0_ = "conjure.timer"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local defer = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function defer0(f, ms)
      local t = vim.loop.new_timer()
      t:start(ms, 0, vim.schedule_wrap(f))
      return t
    end
    v_23_0_0 = defer0
    _0_0["defer"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["defer"] = v_23_0_
  defer = v_23_0_
end
local destroy = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function destroy0(t)
      if t then
        t:stop()
        t:close()
      end
      return nil
    end
    v_23_0_0 = destroy0
    _0_0["destroy"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["destroy"] = v_23_0_
  destroy = v_23_0_
end
return nil