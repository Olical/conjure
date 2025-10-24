-- [nfnl] fnl/conjure/promise.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local uuid = autoload("conjure.uuid")
local M = define("conjure.promise")
local state = {}
M.new = function()
  local id = uuid.v4()
  core.assoc(state, id, {id = id, val = nil, ["done?"] = false})
  return id
end
M["done?"] = function(id)
  return core["get-in"](state, {id, "done?"})
end
M.deliver = function(id, val)
  if (false == M["done?"](id)) then
    core["assoc-in"](state, {id, "val"}, val)
    core["assoc-in"](state, {id, "done?"}, true)
  else
  end
  return nil
end
M["deliver-fn"] = function(id)
  local function _3_(_241)
    return M.deliver(id, _241)
  end
  return _3_
end
M.close = function(id)
  local val = core["get-in"](state, {id, "val"})
  core.assoc(state, id, nil)
  return val
end
M.await = function(id, opts)
  return vim.fn.wait(core.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), core.get(opts, "interval", 50))
end
return M
