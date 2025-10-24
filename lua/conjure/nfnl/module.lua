-- [nfnl] fnl/nfnl/module.fnl
local module_key = "nfnl/autoload-module"
local enabled_key = "nfnl/autoload-enabled?"
local M = {}
M.autoload = function(name)
  local res = {[enabled_key] = true, [module_key] = false}
  local ensure
  local function _1_()
    if res[module_key] then
      return res[module_key]
    else
      local m = require(name)
      res[module_key] = m
      return m
    end
  end
  ensure = _1_
  local function _3_(_t, ...)
    return ensure()(...)
  end
  local function _4_(_t, k)
    return ensure()[k]
  end
  local function _5_(_t, k, v)
    ensure()[k] = v
    return nil
  end
  return setmetatable(res, {__call = _3_, __index = _4_, __newindex = _5_})
end
M.define = function(mod_name, base)
  local loaded = package.loaded[mod_name]
  if (((type(loaded) == type(base)) or (nil == base)) and ((nil ~= loaded) and ("number" ~= type(loaded)))) then
    return loaded
  else
    return (base or {})
  end
end
return M
