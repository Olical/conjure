local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.promise"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.uuid")}
local a = _local_0_[1]
local nvim = _local_0_[2]
local uuid = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.promise"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state = {}
local new
do
  local v_0_
  local function new0()
    local id = uuid.v4()
    a.assoc(state, id, {["done?"] = false, id = id, val = nil})
    return id
  end
  v_0_ = new0
  _0_0["new"] = v_0_
  new = v_0_
end
local done_3f
do
  local v_0_
  local function done_3f0(id)
    return a["get-in"](state, {id, "done?"})
  end
  v_0_ = done_3f0
  _0_0["done?"] = v_0_
  done_3f = v_0_
end
local deliver
do
  local v_0_
  local function deliver0(id, val)
    if (false == done_3f(id)) then
      a["assoc-in"](state, {id, "val"}, val)
      a["assoc-in"](state, {id, "done?"}, true)
    end
    return nil
  end
  v_0_ = deliver0
  _0_0["deliver"] = v_0_
  deliver = v_0_
end
local deliver_fn
do
  local v_0_
  local function deliver_fn0(id)
    local function _1_(_241)
      return deliver(id, _241)
    end
    return _1_
  end
  v_0_ = deliver_fn0
  _0_0["deliver-fn"] = v_0_
  deliver_fn = v_0_
end
local close
do
  local v_0_
  local function close0(id)
    local val = a["get-in"](state, {id, "val"})
    a.assoc(state, id, nil)
    return val
  end
  v_0_ = close0
  _0_0["close"] = v_0_
  close = v_0_
end
local await
do
  local v_0_
  local function await0(id, opts)
    return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
  end
  v_0_ = await0
  _0_0["await"] = v_0_
  await = v_0_
end
return nil