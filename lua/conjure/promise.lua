local _0_0 = nil
do
  local name_0_ = "conjure.promise"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", uuid = "conjure.uuid"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local nvim = _1_[2]
local uuid = _1_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.promise"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state = nil
do
  local v_0_ = (_0_0["aniseed/locals"].state or {})
  _0_0["aniseed/locals"]["state"] = v_0_
  state = v_0_
end
local new = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function new0()
      local id = uuid.v4()
      a.assoc(state, id, {["done?"] = false, id = id, val = nil})
      return id
    end
    v_0_0 = new0
    _0_0["new"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["new"] = v_0_
  new = v_0_
end
local done_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function done_3f0(id)
      return a["get-in"](state, {id, "done?"})
    end
    v_0_0 = done_3f0
    _0_0["done?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["done?"] = v_0_
  done_3f = v_0_
end
local deliver = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function deliver0(id, val)
      if (false == done_3f(id)) then
        a["assoc-in"](state, {id, "val"}, val)
        a["assoc-in"](state, {id, "done?"}, true)
      end
      return nil
    end
    v_0_0 = deliver0
    _0_0["deliver"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["deliver"] = v_0_
  deliver = v_0_
end
local deliver_fn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function deliver_fn0(id)
      local function _3_(_241)
        return deliver(id, _241)
      end
      return _3_
    end
    v_0_0 = deliver_fn0
    _0_0["deliver-fn"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["deliver-fn"] = v_0_
  deliver_fn = v_0_
end
local close = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function close0(id)
      local val = a["get-in"](state, {id, "val"})
      a.assoc(state, id, nil)
      return val
    end
    v_0_0 = close0
    _0_0["close"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["close"] = v_0_
  close = v_0_
end
local await = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function await0(id, opts)
      return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
    end
    v_0_0 = await0
    _0_0["await"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["await"] = v_0_
  await = v_0_
end
return nil