local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.dynamic"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local config = _local_0_[2]
local dyn = _local_0_[3]
local fennel = _local_0_[4]
local nvim = _local_0_[5]
local str = _local_0_[6]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state_key
do
  local v_0_
  local function _1_()
    return "default"
  end
  v_0_ = dyn.new(_1_)
  _0_0["state-key"] = v_0_
  state_key = v_0_
end
local state = {["state-key-set?"] = false}
local set_state_key_21
do
  local v_0_
  local function set_state_key_210(new_key)
    state["state-key-set?"] = true
    local function _1_()
      return new_key
    end
    return dyn["set-root!"](state_key, _1_)
  end
  v_0_ = set_state_key_210
  _0_0["set-state-key!"] = v_0_
  set_state_key_21 = v_0_
end
local multiple_states_3f
do
  local v_0_
  local function multiple_states_3f0()
    return state["state-key-set?"]
  end
  v_0_ = multiple_states_3f0
  _0_0["multiple-states?"] = v_0_
  multiple_states_3f = v_0_
end
local new_state
do
  local v_0_
  local function new_state0(init_fn)
    local key__3estate = {}
    local function _1_(...)
      local key = state_key()
      local state0 = a.get(key__3estate, key)
      local _2_
      if (nil == state0) then
        local new_state1 = init_fn()
        a.assoc(key__3estate, key, new_state1)
        _2_ = new_state1
      else
        _2_ = state0
      end
      return a["get-in"](_2_, {...})
    end
    return _1_
  end
  v_0_ = new_state0
  _0_0["new-state"] = v_0_
  new_state = v_0_
end
local loaded = {}
local function load_module(ft, name)
  local ok_3f, result = nil, nil
  local function _1_()
    return require(name)
  end
  ok_3f, result = xpcall(_1_, fennel.traceback)
  if (ok_3f and a["nil?"](a.get(loaded, name))) then
    a.assoc(loaded, name, {["module-name"] = name, filetype = ft, module = result})
    if (result["on-load"] and not nvim.wo.diff) then
      vim.schedule(result["on-load"])
    end
  end
  if ok_3f then
    return result
  else
    return error(result)
  end
end
local filetype
local function _1_()
  return nvim.bo.filetype
end
filetype = dyn.new(_1_)
local extension
local function _2_()
  return nvim.fn.expand("%:e")
end
extension = dyn.new(_2_)
local with_filetype
do
  local v_0_
  local function with_filetype0(ft, f, ...)
    local function _3_()
      return nil
    end
    local function _4_()
      return ft
    end
    return dyn.bind({[extension] = _3_, [filetype] = _4_}, f, ...)
  end
  v_0_ = with_filetype0
  _0_0["with-filetype"] = v_0_
  with_filetype = v_0_
end
local wrap
do
  local v_0_
  local function wrap0(f, ...)
    local opts = {[filetype] = a.constantly(filetype()), [state_key] = a.constantly(state_key())}
    local args = {...}
    local function _3_(...)
      if (0 ~= a.count(args)) then
        return dyn.bind(opts, f, unpack(args), ...)
      else
        return dyn.bind(opts, f, ...)
      end
    end
    return _3_
  end
  v_0_ = wrap0
  _0_0["wrap"] = v_0_
  wrap = v_0_
end
local schedule_wrap
do
  local v_0_
  local function schedule_wrap0(f, ...)
    return wrap(vim.schedule_wrap(f), ...)
  end
  v_0_ = schedule_wrap0
  _0_0["schedule-wrap"] = v_0_
  schedule_wrap = v_0_
end
local schedule
do
  local v_0_
  local function schedule0(f, ...)
    return vim.schedule(wrap(f, ...))
  end
  v_0_ = schedule0
  _0_0["schedule"] = v_0_
  schedule = v_0_
end
local function current_client_module_name()
  local result = {["module-name"] = nil, extension = extension(), filetype = filetype()}
  do
    local fts
    if result.filetype then
      fts = str.split(result.filetype, "%.")
    else
    fts = nil
    end
    if fts then
      for i = a.count(fts), 1, -1 do
        local ft_part = fts[i]
        local module_name = config["get-in"]({"filetype", ft_part})
        local suffixes = config["get-in"]({"filetype_suffixes", ft_part})
        local function _4_(_241)
          return (result.extension == _241)
        end
        if (not result["module-name"] and module_name and (not suffixes or not result.extension or a.some(_4_, suffixes))) then
          result["module-name"] = module_name
        end
      end
    end
  end
  return result
end
local current
do
  local v_0_
  local function current0()
    local _let_0_ = current_client_module_name()
    local extension0 = _let_0_["extension"]
    local filetype0 = _let_0_["filetype"]
    local module_name = _let_0_["module-name"]
    if module_name then
      return load_module(filetype0, module_name)
    end
  end
  v_0_ = current0
  _0_0["current"] = v_0_
  current = v_0_
end
local get
do
  local v_0_
  local function get0(...)
    return a["get-in"](current(), {...})
  end
  v_0_ = get0
  _0_0["get"] = v_0_
  get = v_0_
end
local call
do
  local v_0_
  local function call0(fn_name, ...)
    local f = get(fn_name)
    if f then
      return f(...)
    else
      return error(("Conjure client '" .. a.get(current_client_module_name(), "module-name") .. "' doesn't support function: " .. fn_name))
    end
  end
  v_0_ = call0
  _0_0["call"] = v_0_
  call = v_0_
end
local optional_call
do
  local v_0_
  local function optional_call0(fn_name, ...)
    local f = get(fn_name)
    if f then
      return f(...)
    end
  end
  v_0_ = optional_call0
  _0_0["optional-call"] = v_0_
  optional_call = v_0_
end
local each_loaded_client
do
  local v_0_
  local function each_loaded_client0(f)
    local function _4_(_3_0)
      local _arg_0_ = _3_0
      local filetype0 = _arg_0_["filetype"]
      return with_filetype(filetype0, f)
    end
    return a["run!"](_4_, a.vals(loaded))
  end
  v_0_ = each_loaded_client0
  _0_0["each-loaded-client"] = v_0_
  each_loaded_client = v_0_
end
return nil