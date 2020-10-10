local _0_0 = nil
do
  local name_0_ = "conjure.dynamic"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.dynamic"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local get_stack_key = nil
do
  local v_0_ = "conjure.dynamic/get-stack"
  _0_0["aniseed/locals"]["get-stack-key"] = v_0_
  get_stack_key = v_0_
end
local assert_value_function_21 = nil
do
  local v_0_ = nil
  local function assert_value_function_210(value)
    if ("function" ~= type(value)) then
      return error("conjure.dynamic values must always be wrapped in a function")
    end
  end
  v_0_ = assert_value_function_210
  _0_0["aniseed/locals"]["assert-value-function!"] = v_0_
  assert_value_function_21 = v_0_
end
local new = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function new0(base_value)
      assert_value_function_21(base_value)
      local stack = {base_value}
      local function _3_(x, ...)
        if (get_stack_key == x) then
          return stack
        else
          return a.last(stack)(x, ...)
        end
      end
      return _3_
    end
    v_0_0 = new0
    _0_0["new"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["new"] = v_0_
  new = v_0_
end
local run_binds_21 = nil
do
  local v_0_ = nil
  local function run_binds_210(f, binds)
    local function _3_(_4_0)
      local _5_ = _4_0
      local dyn = _5_[1]
      local new_value = _5_[2]
      assert_value_function_21(new_value)
      return f(dyn(get_stack_key), new_value)
    end
    return a["map-indexed"](_3_, binds)
  end
  v_0_ = run_binds_210
  _0_0["aniseed/locals"]["run-binds!"] = v_0_
  run_binds_21 = v_0_
end
local bind = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function bind0(binds, f, ...)
      run_binds_21(table.insert, binds)
      local ok_3f, result = pcall(f, ...)
      local function _3_(_241)
        return table.remove(_241)
      end
      run_binds_21(_3_, binds)
      if ok_3f then
        return result
      else
        return error(result)
      end
    end
    v_0_0 = bind0
    _0_0["bind"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["bind"] = v_0_
  bind = v_0_
end
local set_21 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function set_210(dyn, new_value)
      assert_value_function_21(new_value)
      do
        local stack = dyn(get_stack_key)
        local depth = a.count(stack)
        a.assoc(stack, depth, new_value)
      end
      return nil
    end
    v_0_0 = set_210
    _0_0["set!"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["set!"] = v_0_
  set_21 = v_0_
end
local set_root_21 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function set_root_210(dyn, new_value)
      assert_value_function_21(new_value)
      a.assoc(dyn(get_stack_key), 1, new_value)
      return nil
    end
    v_0_0 = set_root_210
    _0_0["set-root!"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["set-root!"] = v_0_
  set_root_21 = v_0_
end
return nil