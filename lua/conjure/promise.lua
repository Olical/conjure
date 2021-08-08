local _2afile_2a = "fnl/conjure/promise.fnl"
local _1_
do
  local name_4_auto = "conjure.promise"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.uuid")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", uuid = "conjure.uuid"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local uuid = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.promise"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local state
do
  local v_23_auto = ((_1_)["aniseed/locals"].state or {})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local new
do
  local v_23_auto
  do
    local v_25_auto
    local function new0()
      local id = uuid.v4()
      a.assoc(state, id, {["done?"] = false, id = id, val = nil})
      return id
    end
    v_25_auto = new0
    _1_["new"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["new"] = v_23_auto
  new = v_23_auto
end
local done_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function done_3f0(id)
      return a["get-in"](state, {id, "done?"})
    end
    v_25_auto = done_3f0
    _1_["done?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["done?"] = v_23_auto
  done_3f = v_23_auto
end
local deliver
do
  local v_23_auto
  do
    local v_25_auto
    local function deliver0(id, val)
      if (false == done_3f(id)) then
        a["assoc-in"](state, {id, "val"}, val)
        a["assoc-in"](state, {id, "done?"}, true)
      end
      return nil
    end
    v_25_auto = deliver0
    _1_["deliver"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["deliver"] = v_23_auto
  deliver = v_23_auto
end
local deliver_fn
do
  local v_23_auto
  do
    local v_25_auto
    local function deliver_fn0(id)
      local function _9_(_241)
        return deliver(id, _241)
      end
      return _9_
    end
    v_25_auto = deliver_fn0
    _1_["deliver-fn"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["deliver-fn"] = v_23_auto
  deliver_fn = v_23_auto
end
local close
do
  local v_23_auto
  do
    local v_25_auto
    local function close0(id)
      local val = a["get-in"](state, {id, "val"})
      a.assoc(state, id, nil)
      return val
    end
    v_25_auto = close0
    _1_["close"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close"] = v_23_auto
  close = v_23_auto
end
local await
do
  local v_23_auto
  do
    local v_25_auto
    local function await0(id, opts)
      return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
    end
    v_25_auto = await0
    _1_["await"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["await"] = v_23_auto
  await = v_23_auto
end
return nil