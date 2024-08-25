-- [nfnl] Compiled from fnl/conjure/promise.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local uuid = autoload("conjure.uuid")
local state = {}
local function new()
  local id = uuid.v4()
  a.assoc(state, id, {id = id, val = nil, ["done?"] = false})
  return id
end
local function done_3f(id)
  return a["get-in"](state, {id, "done?"})
end
local function deliver(id, val)
  if (false == done_3f(id)) then
    a["assoc-in"](state, {id, "val"}, val)
    a["assoc-in"](state, {id, "done?"}, true)
  else
  end
  return nil
end
local function deliver_fn(id)
  local function _3_(_241)
    return deliver(id, _241)
  end
  return _3_
end
local function close(id)
  local val = a["get-in"](state, {id, "val"})
  a.assoc(state, id, nil)
  return val
end
local function await(id, opts)
  return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
end
return {new = new, ["done?"] = done_3f, deliver = deliver, ["deliver-fn"] = deliver_fn, close = close, await = await}
