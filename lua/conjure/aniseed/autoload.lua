local _2afile_2a = "fnl/aniseed/autoload.fnl"
local _2amodule_name_2a = "conjure.aniseed.autoload"
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
local function autoload(name)
  local res = {["aniseed/autoload-enabled?"] = true, ["aniseed/autoload-module"] = false}
  local function ensure()
    if res["aniseed/autoload-module"] then
      return res["aniseed/autoload-module"]
    else
      local m = require(name)
      do end (res)["aniseed/autoload-module"] = m
      return m
    end
  end
  local function _2_(t, ...)
    return ensure()(...)
  end
  local function _3_(t, k)
    return ensure()[k]
  end
  local function _4_(t, k, v)
    ensure()[k] = v
    return nil
  end
  return setmetatable(res, {__call = _2_, __index = _3_, __newindex = _4_})
end
_2amodule_2a["autoload"] = autoload
return _2amodule_2a
