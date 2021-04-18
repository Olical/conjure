local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.dynamic"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core")}
local a = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.dynamic"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local get_stack_key = "conjure.dynamic/get-stack"
local function assert_value_function_21(value)
  if ("function" ~= type(value)) then
    return error("conjure.dynamic values must always be wrapped in a function")
  end
end
local new
do
  local v_0_
  local function new0(base_value)
    assert_value_function_21(base_value)
    local stack = {base_value}
    local function _1_(x, ...)
      if (get_stack_key == x) then
        return stack
      else
        return a.last(stack)(x, ...)
      end
    end
    return _1_
  end
  v_0_ = new0
  _0_0["new"] = v_0_
  new = v_0_
end
local function run_binds_21(f, binds)
  local function _2_(_1_0)
    local _arg_0_ = _1_0
    local dyn = _arg_0_[1]
    local new_value = _arg_0_[2]
    assert_value_function_21(new_value)
    return f(dyn(get_stack_key), new_value)
  end
  return a["map-indexed"](_2_, binds)
end
local bind
do
  local v_0_
  local function bind0(binds, f, ...)
    run_binds_21(table.insert, binds)
    local ok_3f, result = pcall(f, ...)
    local function _1_(_241)
      return table.remove(_241)
    end
    run_binds_21(_1_, binds)
    if ok_3f then
      return result
    else
      return error(result)
    end
  end
  v_0_ = bind0
  _0_0["bind"] = v_0_
  bind = v_0_
end
local set_21
do
  local v_0_
  local function set_210(dyn, new_value)
    assert_value_function_21(new_value)
    do
      local stack = dyn(get_stack_key)
      local depth = a.count(stack)
      a.assoc(stack, depth, new_value)
    end
    return nil
  end
  v_0_ = set_210
  _0_0["set!"] = v_0_
  set_21 = v_0_
end
local set_root_21
do
  local v_0_
  local function set_root_210(dyn, new_value)
    assert_value_function_21(new_value)
    a.assoc(dyn(get_stack_key), 1, new_value)
    return nil
  end
  v_0_ = set_root_210
  _0_0["set-root!"] = v_0_
  set_root_21 = v_0_
end
return nil