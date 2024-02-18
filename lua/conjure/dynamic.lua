-- [nfnl] Compiled from fnl/conjure/dynamic.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.dynamic"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
local bind = (_2amodule_2a).bind
local new = (_2amodule_2a).new
local set_21 = (_2amodule_2a)["set!"]
local set_root_21 = (_2amodule_2a)["set-root!"]
local a0 = (_2amodule_locals_2a).a
local assert_value_function_21 = (_2amodule_locals_2a)["assert-value-function!"]
local get_stack_key = (_2amodule_locals_2a)["get-stack-key"]
local run_binds_21 = (_2amodule_locals_2a)["run-binds!"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local get_stack_key0 = "conjure.dynamic/get-stack"
_2amodule_locals_2a["get-stack-key"] = get_stack_key0
do local _ = {nil, nil} end
local function assert_value_function_210(value)
  if ("function" ~= type(value)) then
    return error("conjure.dynamic values must always be wrapped in a function")
  else
    return nil
  end
end
_2amodule_locals_2a["assert-value-function!"] = assert_value_function_210
do local _ = {assert_value_function_210, nil} end
local function new0(base_value)
  assert_value_function_210(base_value)
  local stack = {base_value}
  local function _2_(x, ...)
    if (get_stack_key0 == x) then
      return stack
    else
      return a0.last(stack)(x, ...)
    end
  end
  return _2_
end
_2amodule_2a["new"] = new0
do local _ = {new0, nil} end
local function run_binds_210(f, binds)
  local function _6_(_4_)
    local _arg_5_ = _4_
    local dyn = _arg_5_[1]
    local new_value = _arg_5_[2]
    assert_value_function_210(new_value)
    return f(dyn(get_stack_key0), new_value)
  end
  return a0["map-indexed"](_6_, binds)
end
_2amodule_locals_2a["run-binds!"] = run_binds_210
do local _ = {run_binds_210, nil} end
local function bind0(binds, f, ...)
  run_binds_210(table.insert, binds)
  local ok_3f, result = pcall(f, ...)
  local function _7_(_241)
    return table.remove(_241)
  end
  run_binds_210(_7_, binds)
  if ok_3f then
    return result
  else
    return error(result)
  end
end
_2amodule_2a["bind"] = bind0
do local _ = {bind0, nil} end
local function set_210(dyn, new_value)
  assert_value_function_210(new_value)
  do
    local stack = dyn(get_stack_key0)
    local depth = a0.count(stack)
    a0.assoc(stack, depth, new_value)
  end
  return nil
end
_2amodule_2a["set!"] = set_210
do local _ = {set_210, nil} end
local function set_root_210(dyn, new_value)
  assert_value_function_210(new_value)
  a0.assoc(dyn(get_stack_key0), 1, new_value)
  return nil
end
_2amodule_2a["set-root!"] = set_root_210
do local _ = {set_root_210, nil} end
return _2amodule_2a
