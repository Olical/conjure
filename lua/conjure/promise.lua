local _2afile_2a = "fnl/conjure/promise.fnl"
local _2amodule_name_2a = "conjure.promise"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, nvim, uuid = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.uuid")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["uuid"] = uuid
local state = ((_2amodule_2a).state or {})
do end (_2amodule_locals_2a)["state"] = state
local function new()
  local id = uuid.v4()
  a.assoc(state, id, {id = id, val = nil, ["done?"] = false})
  return id
end
_2amodule_2a["new"] = new
local function done_3f(id)
  return a["get-in"](state, {id, "done?"})
end
_2amodule_2a["done?"] = done_3f
local function deliver(id, val)
  if (false == done_3f(id)) then
    a["assoc-in"](state, {id, "val"}, val)
    a["assoc-in"](state, {id, "done?"}, true)
  else
  end
  return nil
end
_2amodule_2a["deliver"] = deliver
local function deliver_fn(id)
  local function _2_(_241)
    return deliver(id, _241)
  end
  return _2_
end
_2amodule_2a["deliver-fn"] = deliver_fn
local function close(id)
  local val = a["get-in"](state, {id, "val"})
  a.assoc(state, id, nil)
  return val
end
_2amodule_2a["close"] = close
local function await(id, opts)
  return nvim.fn.wait(a.get(opts, "timeout", 10000), ("luaeval(\"require('conjure.promise')['done?']('" .. id .. "')\")"), a.get(opts, "interval", 50))
end
_2amodule_2a["await"] = await
return _2amodule_2a