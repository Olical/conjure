-- [nfnl] fnl/conjure/dynamic.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local M = define("conjure.dynamic")
local get_stack_key = "conjure.dynamic/get-stack"
local function assert_value_function_21(value)
  if ("function" ~= type(value)) then
    return error("conjure.dynamic values must always be wrapped in a function")
  else
    return nil
  end
end
M.new = function(base_value)
  assert_value_function_21(base_value)
  local stack = {base_value}
  local function _3_(x, ...)
    if (get_stack_key == x) then
      return stack
    else
      return core.last(stack)(x, ...)
    end
  end
  return _3_
end
local function run_binds_21(f, binds)
  local function _6_(_5_)
    local dyn = _5_[1]
    local new_value = _5_[2]
    assert_value_function_21(new_value)
    return f(dyn(get_stack_key), new_value)
  end
  return core["map-indexed"](_6_, binds)
end
M.bind = function(binds, f, ...)
  run_binds_21(table.insert, binds)
  local ok_3f, result = pcall(f, ...)
  local function _7_(_241)
    return table.remove(_241)
  end
  run_binds_21(_7_, binds)
  if ok_3f then
    return result
  else
    return error(result)
  end
end
M["set!"] = function(dyn, new_value)
  assert_value_function_21(new_value)
  do
    local stack = dyn(get_stack_key)
    local depth = core.count(stack)
    core.assoc(stack, depth, new_value)
  end
  return nil
end
M["set-root!"] = function(dyn, new_value)
  assert_value_function_21(new_value)
  core.assoc(dyn(get_stack_key), 1, new_value)
  return nil
end
return M
