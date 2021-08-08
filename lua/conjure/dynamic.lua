local _2afile_2a = "fnl/conjure/dynamic.fnl"
local _1_
do
  local name_4_auto = "conjure.dynamic"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.dynamic"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local get_stack_key
do
  local v_23_auto = "conjure.dynamic/get-stack"
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-stack-key"] = v_23_auto
  get_stack_key = v_23_auto
end
local assert_value_function_21
do
  local v_23_auto
  local function assert_value_function_210(value)
    if ("function" ~= type(value)) then
      return error("conjure.dynamic values must always be wrapped in a function")
    end
  end
  v_23_auto = assert_value_function_210
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assert-value-function!"] = v_23_auto
  assert_value_function_21 = v_23_auto
end
local new
do
  local v_23_auto
  do
    local v_25_auto
    local function new0(base_value)
      assert_value_function_21(base_value)
      local stack = {base_value}
      local function _9_(x, ...)
        if (get_stack_key == x) then
          return stack
        else
          return a.last(stack)(x, ...)
        end
      end
      return _9_
    end
    v_25_auto = new0
    _1_["new"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["new"] = v_23_auto
  new = v_23_auto
end
local run_binds_21
do
  local v_23_auto
  local function run_binds_210(f, binds)
    local function _13_(_11_)
      local _arg_12_ = _11_
      local dyn = _arg_12_[1]
      local new_value = _arg_12_[2]
      assert_value_function_21(new_value)
      return f(dyn(get_stack_key), new_value)
    end
    return a["map-indexed"](_13_, binds)
  end
  v_23_auto = run_binds_210
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run-binds!"] = v_23_auto
  run_binds_21 = v_23_auto
end
local bind
do
  local v_23_auto
  do
    local v_25_auto
    local function bind0(binds, f, ...)
      run_binds_21(table.insert, binds)
      local ok_3f, result = pcall(f, ...)
      local function _14_(_241)
        return table.remove(_241)
      end
      run_binds_21(_14_, binds)
      if ok_3f then
        return result
      else
        return error(result)
      end
    end
    v_25_auto = bind0
    _1_["bind"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["bind"] = v_23_auto
  bind = v_23_auto
end
local set_21
do
  local v_23_auto
  do
    local v_25_auto
    local function set_210(dyn, new_value)
      assert_value_function_21(new_value)
      do
        local stack = dyn(get_stack_key)
        local depth = a.count(stack)
        a.assoc(stack, depth, new_value)
      end
      return nil
    end
    v_25_auto = set_210
    _1_["set!"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["set!"] = v_23_auto
  set_21 = v_23_auto
end
local set_root_21
do
  local v_23_auto
  do
    local v_25_auto
    local function set_root_210(dyn, new_value)
      assert_value_function_21(new_value)
      a.assoc(dyn(get_stack_key), 1, new_value)
      return nil
    end
    v_25_auto = set_root_210
    _1_["set-root!"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["set-root!"] = v_23_auto
  set_root_21 = v_23_auto
end
return nil