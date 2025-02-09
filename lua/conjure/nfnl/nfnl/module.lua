-- [nfnl] Compiled from fnl/nfnl/module.fnl by https://github.com/Olical/nfnl, do not edit.
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
  local function _3_(t, ...)
    return ensure()(...)
  end
  local function _4_(t, k)
    return ensure()[k]
  end
  local function _5_(t, k, v)
    ensure()[k] = v
    return nil
  end
  return setmetatable(res, {__call = _3_, __index = _4_, __newindex = _5_})
end
M.define = function(mod_name, base)
  local loaded = package.loaded[mod_name]
  if (type(loaded) == type(base)) then
    return loaded
  else
    return base
  end
end
return M
