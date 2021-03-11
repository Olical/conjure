local _0_0 = nil
do
  local name_0_ = "conjure.client"
  local module_0_ = nil
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
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.dynamic"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config", dyn = "conjure.dynamic", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local config = _local_0_[2]
local dyn = _local_0_[3]
local fennel = _local_0_[4]
local nvim = _local_0_[5]
local str = _local_0_[6]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state_key = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function _2_()
      return "default"
    end
    v_0_0 = ((_0_0)["state-key"] or dyn.new(_2_))
    _0_0["state-key"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["state-key"] = v_0_
  state_key = v_0_
end
local state = nil
do
  local v_0_ = (((_0_0)["aniseed/locals"]).state or {["state-key-set?"] = false})
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["state"] = v_0_
  state = v_0_
end
local set_state_key_21 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function set_state_key_210(new_key)
      state["state-key-set?"] = true
      local function _2_()
        return new_key
      end
      return dyn["set-root!"](state_key, _2_)
    end
    v_0_0 = set_state_key_210
    _0_0["set-state-key!"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["set-state-key!"] = v_0_
  set_state_key_21 = v_0_
end
local multiple_states_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function multiple_states_3f0()
      return state["state-key-set?"]
    end
    v_0_0 = multiple_states_3f0
    _0_0["multiple-states?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["multiple-states?"] = v_0_
  multiple_states_3f = v_0_
end
local new_state = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function new_state0(init_fn)
      local key__3estate = {}
      local function _2_(...)
        local key = state_key()
        local state0 = a.get(key__3estate, key)
        local _3_
        if (nil == state0) then
          local new_state1 = init_fn()
          a.assoc(key__3estate, key, new_state1)
          _3_ = new_state1
        else
          _3_ = state0
        end
        return a["get-in"](_3_, {...})
      end
      return _2_
    end
    v_0_0 = new_state0
    _0_0["new-state"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["new-state"] = v_0_
  new_state = v_0_
end
local loaded = nil
do
  local v_0_ = (((_0_0)["aniseed/locals"]).loaded or {})
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["loaded"] = v_0_
  loaded = v_0_
end
local load_module = nil
do
  local v_0_ = nil
  local function load_module0(ft, name)
    local ok_3f, result = nil, nil
    local function _2_()
      return require(name)
    end
    ok_3f, result = xpcall(_2_, fennel.traceback)
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
  v_0_ = load_module0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["load-module"] = v_0_
  load_module = v_0_
end
local filetype = nil
do
  local v_0_ = nil
  local function _2_()
    return nvim.bo.filetype
  end
  v_0_ = dyn.new(_2_)
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["filetype"] = v_0_
  filetype = v_0_
end
local with_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function with_filetype0(ft, f, ...)
      local function _2_()
        return ft
      end
      return dyn.bind({[filetype] = _2_}, f, ...)
    end
    v_0_0 = with_filetype0
    _0_0["with-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-filetype"] = v_0_
  with_filetype = v_0_
end
local wrap = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function wrap0(f, ...)
      local opts = {[filetype] = a.constantly(filetype()), [state_key] = a.constantly(state_key())}
      local args = {...}
      local function _2_(...)
        if (0 ~= a.count(args)) then
          return dyn.bind(opts, f, unpack(args), ...)
        else
          return dyn.bind(opts, f, ...)
        end
      end
      return _2_
    end
    v_0_0 = wrap0
    _0_0["wrap"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["wrap"] = v_0_
  wrap = v_0_
end
local schedule_wrap = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function schedule_wrap0(f, ...)
      return wrap(vim.schedule_wrap(f), ...)
    end
    v_0_0 = schedule_wrap0
    _0_0["schedule-wrap"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["schedule-wrap"] = v_0_
  schedule_wrap = v_0_
end
local schedule = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function schedule0(f, ...)
      return vim.schedule(wrap(f, ...))
    end
    v_0_0 = schedule0
    _0_0["schedule"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["schedule"] = v_0_
  schedule = v_0_
end
local current_client_module_name = nil
do
  local v_0_ = nil
  local function current_client_module_name0()
    local result = {["module-name"] = nil, extension = nvim.fn.expand("%:e"), filetype = filetype()}
    do
      local fts = nil
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
          local function _3_(_241)
            return (result.extension == _241)
          end
          if (not result["module-name"] and module_name and (not suffixes or a.some(_3_, suffixes))) then
            result["module-name"] = module_name
          end
        end
      end
    end
    return result
  end
  v_0_ = current_client_module_name0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["current-client-module-name"] = v_0_
  current_client_module_name = v_0_
end
local current = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function current0()
      local _let_0_ = current_client_module_name()
      local extension = _let_0_["extension"]
      local filetype0 = _let_0_["filetype"]
      local module_name = _let_0_["module-name"]
      if module_name then
        return load_module(filetype0, module_name)
      else
        return error(("No Conjure client for filetype / extension: '" .. (filetype0 or "nil") .. " / " .. (extension or "nil") .. "'"))
      end
    end
    v_0_0 = current0
    _0_0["current"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["current"] = v_0_
  current = v_0_
end
local get = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get0(...)
      return a["get-in"](current(), {...})
    end
    v_0_0 = get0
    _0_0["get"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get"] = v_0_
  get = v_0_
end
local call = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function call0(fn_name, ...)
      local f = get(fn_name)
      if f then
        return f(...)
      else
        return error(("Conjure client '" .. a.get(current_client_module_name(), "module-name") .. "' doesn't support function: " .. fn_name))
      end
    end
    v_0_0 = call0
    _0_0["call"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["call"] = v_0_
  call = v_0_
end
local optional_call = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function optional_call0(fn_name, ...)
      local f = get(fn_name)
      if f then
        return f(...)
      end
    end
    v_0_0 = optional_call0
    _0_0["optional-call"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["optional-call"] = v_0_
  optional_call = v_0_
end
local each_loaded_client = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function each_loaded_client0(f)
      local function _2_(_3_0)
        local _arg_0_ = _3_0
        local filetype0 = _arg_0_["filetype"]
        return with_filetype(filetype0, f)
      end
      return a["run!"](_2_, a.vals(loaded))
    end
    v_0_0 = each_loaded_client0
    _0_0["each-loaded-client"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["each-loaded-client"] = v_0_
  each_loaded_client = v_0_
end
return nil