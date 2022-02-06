local _2afile_2a = "fnl/conjure/dynamic.fnl"
local _2amodule_name_2a = "conjure.dynamic"
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
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
local get_stack_key = "conjure.dynamic/get-stack"
_2amodule_locals_2a["get-stack-key"] = get_stack_key
local function assert_value_function_21(value)
  if ("function" ~= type(value)) then
    return error("conjure.dynamic values must always be wrapped in a function")
  else
    return nil
  end
end
_2amodule_locals_2a["assert-value-function!"] = assert_value_function_21
local function new(base_value)
  assert_value_function_21(base_value)
  local stack = {base_value}
  local function _2_(x, ...)
    if (get_stack_key == x) then
      return stack
    else
      return a.last(stack)(x, ...)
    end
  end
  return _2_
end
_2amodule_2a["new"] = new
local function run_binds_21(f, binds)
  local function _6_(_4_)
    local _arg_5_ = _4_
    local dyn = _arg_5_[1]
    local new_value = _arg_5_[2]
    assert_value_function_21(new_value)
    return f(dyn(get_stack_key), new_value)
  end
  return a["map-indexed"](_6_, binds)
end
_2amodule_locals_2a["run-binds!"] = run_binds_21
local function bind(binds, f, ...)
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
_2amodule_2a["bind"] = bind
local function set_21(dyn, new_value)
  assert_value_function_21(new_value)
  do
    local stack = dyn(get_stack_key)
    local depth = a.count(stack)
    a.assoc(stack, depth, new_value)
  end
  return nil
end
_2amodule_2a["set!"] = set_21
local function set_root_21(dyn, new_value)
  assert_value_function_21(new_value)
  a.assoc(dyn(get_stack_key), 1, new_value)
  return nil
end
_2amodule_2a["set-root!"] = set_root_21
return _2amodule_2a