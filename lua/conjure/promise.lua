local _2afile_2a = "fnl/conjure/promise.fnl"
local _0_
do
  local name_0_ = "conjure.promise"
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
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", uuid = "conjure.uuid"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local uuid = _local_0_[3]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.promise"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local state
do
  local v_0_ = ((_0_)["aniseed/locals"].state or {})
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["state"] = v_0_
  state = v_0_
end
local new
do
  local v_0_
  do
    local v_0_0
    local function new0()
      local id = uuid.v4()
      a.assoc(state, id, {["done?"] = false, id = id, val = nil})
      return id
    end
    v_0_0 = new0
    _0_["new"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["new"] = v_0_
  new = v_0_
end
local done_3f
do
  local v_0_
  do
    local v_0_0
    local function done_3f0(id)
      return a["get-in"](state, {id, "done?"})
    end
    v_0_0 = done_3f0
    _0_["done?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["done?"] = v_0_
  done_3f = v_0_
end
local deliver
do
  local v_0_
  do
    local v_0_0
    local function deliver0(id, val)
      if (false == done_3f(id)) then
        a["assoc-in"](state, {id, "val"}, val)
        a["assoc-in"](state, {id, "done?"}, true)
      end
      return nil
    end
    v_0_0 = deliver0
    _0_["deliver"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["deliver"] = v_0_
  deliver = v_0_
end
local deliver_fn
do
  local v_0_
  do
    local v_0_0
    local function deliver_fn0(id)
      local function _3_(_241)
        return deliver(id, _241)
      end
      return _3_
    end
    v_0_0 = deliver_fn0
    _0_["deliver-fn"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["deliver-fn"] = v_0_
  deliver_fn = v_0_
end
local close
do
  local v_0_
  do
    local v_0_0
    local function close0(id)
      local val = a["get-in"](state, {id, "val"})
      a.assoc(state, id, nil)
      return val
    end
    v_0_0 = close0
    _0_["close"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["close"] = v_0_
  close = v_0_
end
local await
do
  local v_0_
  do
    local v_0_0
    local function await0(id, opts)
      return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
    end
    v_0_0 = await0
    _0_["await"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["await"] = v_0_
  await = v_0_
end
return nil