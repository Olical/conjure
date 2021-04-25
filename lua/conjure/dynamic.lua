local _0_0
do
  local name_0_ = "conjure.dynamic"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.dynamic"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local get_stack_key
do
  local v_0_ = "conjure.dynamic/get-stack"
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-stack-key"] = v_0_
  get_stack_key = v_0_
end
local assert_value_function_21
do
  local v_0_
  local function assert_value_function_210(value)
    if ("function" ~= type(value)) then
      return error("conjure.dynamic values must always be wrapped in a function")
    end
  end
  v_0_ = assert_value_function_210
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assert-value-function!"] = v_0_
  assert_value_function_21 = v_0_
end
local new
do
  local v_0_
  do
    local v_0_0
    local function new0(base_value)
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
    v_0_0 = new0
    _0_0["new"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["new"] = v_0_
  new = v_0_
end
local run_binds_21
do
  local v_0_
  local function run_binds_210(f, binds)
    local function _3_(_2_0)
      local _arg_0_ = _2_0
      local dyn = _arg_0_[1]
      local new_value = _arg_0_[2]
      assert_value_function_21(new_value)
      return f(dyn(get_stack_key), new_value)
    end
    return a["map-indexed"](_3_, binds)
  end
  v_0_ = run_binds_210
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["run-binds!"] = v_0_
  run_binds_21 = v_0_
end
local bind
do
  local v_0_
  do
    local v_0_0
    local function bind0(binds, f, ...)
      run_binds_21(table.insert, binds)
      local ok_3f, result = pcall(f, ...)
      local function _2_(_241)
        return table.remove(_241)
      end
      run_binds_21(_2_, binds)
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["bind"] = v_0_
  bind = v_0_
end
local set_21
do
  local v_0_
  do
    local v_0_0
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["set!"] = v_0_
  set_21 = v_0_
end
local set_root_21
do
  local v_0_
  do
    local v_0_0
    local function set_root_210(dyn, new_value)
      assert_value_function_21(new_value)
      a.assoc(dyn(get_stack_key), 1, new_value)
      return nil
    end
    v_0_0 = set_root_210
    _0_0["set-root!"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["set-root!"] = v_0_
  set_root_21 = v_0_
end
return nil