local _2afile_2a = "fnl/conjure/client.fnl"
local _1_
do
  local name_4_auto = "conjure.client"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.dynamic"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", config = "conjure.config", dyn = "conjure.dynamic", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local config = _local_4_[2]
local dyn = _local_4_[3]
local fennel = _local_4_[4]
local nvim = _local_4_[5]
local str = _local_4_[6]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local state_key
do
  local v_23_auto
  do
    local v_25_auto
    local function _8_()
      return "default"
    end
    v_25_auto = ((_1_)["state-key"] or dyn.new(_8_))
    do end (_1_)["state-key"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state-key"] = v_23_auto
  state_key = v_23_auto
end
local state
do
  local v_23_auto = ((_1_)["aniseed/locals"].state or {["state-key-set?"] = false})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local set_state_key_21
do
  local v_23_auto
  do
    local v_25_auto
    local function set_state_key_210(new_key)
      state["state-key-set?"] = true
      local function _9_()
        return new_key
      end
      return dyn["set-root!"](state_key, _9_)
    end
    v_25_auto = set_state_key_210
    _1_["set-state-key!"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["set-state-key!"] = v_23_auto
  set_state_key_21 = v_23_auto
end
local multiple_states_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function multiple_states_3f0()
      return state["state-key-set?"]
    end
    v_25_auto = multiple_states_3f0
    _1_["multiple-states?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["multiple-states?"] = v_23_auto
  multiple_states_3f = v_23_auto
end
local new_state
do
  local v_23_auto
  do
    local v_25_auto
    local function new_state0(init_fn)
      local key__3estate = {}
      local function _10_(...)
        local key = state_key()
        local state0 = a.get(key__3estate, key)
        local _11_
        if (nil == state0) then
          local new_state1 = init_fn()
          a.assoc(key__3estate, key, new_state1)
          _11_ = new_state1
        else
          _11_ = state0
        end
        return a["get-in"](_11_, {...})
      end
      return _10_
    end
    v_25_auto = new_state0
    _1_["new-state"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["new-state"] = v_23_auto
  new_state = v_23_auto
end
local loaded
do
  local v_23_auto = ((_1_)["aniseed/locals"].loaded or {})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["loaded"] = v_23_auto
  loaded = v_23_auto
end
local load_module
do
  local v_23_auto
  local function load_module0(ft, name)
    local fnl = fennel.impl()
    local ok_3f, result = nil, nil
    local function _14_()
      return require(name)
    end
    ok_3f, result = xpcall(_14_, fnl.traceback)
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
  v_23_auto = load_module0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["load-module"] = v_23_auto
  load_module = v_23_auto
end
local filetype
do
  local v_23_auto
  local function _18_()
    return nvim.bo.filetype
  end
  v_23_auto = dyn.new(_18_)
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["filetype"] = v_23_auto
  filetype = v_23_auto
end
local extension
do
  local v_23_auto
  local function _19_()
    return nvim.fn.expand("%:e")
  end
  v_23_auto = dyn.new(_19_)
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["extension"] = v_23_auto
  extension = v_23_auto
end
local with_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function with_filetype0(ft, f, ...)
      local function _20_()
        return nil
      end
      local function _21_()
        return ft
      end
      return dyn.bind({[extension] = _20_, [filetype] = _21_}, f, ...)
    end
    v_25_auto = with_filetype0
    _1_["with-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-filetype"] = v_23_auto
  with_filetype = v_23_auto
end
local wrap
do
  local v_23_auto
  do
    local v_25_auto
    local function wrap0(f, ...)
      local opts = {[filetype] = a.constantly(filetype()), [state_key] = a.constantly(state_key())}
      local args = {...}
      local function _22_(...)
        if (0 ~= a.count(args)) then
          return dyn.bind(opts, f, unpack(args), ...)
        else
          return dyn.bind(opts, f, ...)
        end
      end
      return _22_
    end
    v_25_auto = wrap0
    _1_["wrap"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["wrap"] = v_23_auto
  wrap = v_23_auto
end
local schedule_wrap
do
  local v_23_auto
  do
    local v_25_auto
    local function schedule_wrap0(f, ...)
      return wrap(vim.schedule_wrap(f), ...)
    end
    v_25_auto = schedule_wrap0
    _1_["schedule-wrap"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["schedule-wrap"] = v_23_auto
  schedule_wrap = v_23_auto
end
local schedule
do
  local v_23_auto
  do
    local v_25_auto
    local function schedule0(f, ...)
      return vim.schedule(wrap(f, ...))
    end
    v_25_auto = schedule0
    _1_["schedule"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["schedule"] = v_23_auto
  schedule = v_23_auto
end
local current_client_module_name
do
  local v_23_auto
  local function current_client_module_name0()
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
          local function _25_(_241)
            return (result.extension == _241)
          end
          if (not result["module-name"] and module_name and (not suffixes or not result.extension or a.some(_25_, suffixes))) then
            result["module-name"] = module_name
          end
        end
      end
    end
    return result
  end
  v_23_auto = current_client_module_name0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["current-client-module-name"] = v_23_auto
  current_client_module_name = v_23_auto
end
local current
do
  local v_23_auto
  do
    local v_25_auto
    local function current0()
      local _let_28_ = current_client_module_name()
      local extension0 = _let_28_["extension"]
      local filetype0 = _let_28_["filetype"]
      local module_name = _let_28_["module-name"]
      if module_name then
        return load_module(filetype0, module_name)
      end
    end
    v_25_auto = current0
    _1_["current"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["current"] = v_23_auto
  current = v_23_auto
end
local get
do
  local v_23_auto
  do
    local v_25_auto
    local function get0(...)
      return a["get-in"](current(), {...})
    end
    v_25_auto = get0
    _1_["get"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get"] = v_23_auto
  get = v_23_auto
end
local call
do
  local v_23_auto
  do
    local v_25_auto
    local function call0(fn_name, ...)
      local f = get(fn_name)
      if f then
        return f(...)
      else
        return error(("Conjure client '" .. a.get(current_client_module_name(), "module-name") .. "' doesn't support function: " .. fn_name))
      end
    end
    v_25_auto = call0
    _1_["call"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["call"] = v_23_auto
  call = v_23_auto
end
local optional_call
do
  local v_23_auto
  do
    local v_25_auto
    local function optional_call0(fn_name, ...)
      local f = get(fn_name)
      if f then
        return f(...)
      end
    end
    v_25_auto = optional_call0
    _1_["optional-call"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["optional-call"] = v_23_auto
  optional_call = v_23_auto
end
local each_loaded_client
do
  local v_23_auto
  do
    local v_25_auto
    local function each_loaded_client0(f)
      local function _34_(_32_)
        local _arg_33_ = _32_
        local filetype0 = _arg_33_["filetype"]
        return with_filetype(filetype0, f)
      end
      return a["run!"](_34_, a.vals(loaded))
    end
    v_25_auto = each_loaded_client0
    _1_["each-loaded-client"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["each-loaded-client"] = v_23_auto
  each_loaded_client = v_23_auto
end
return nil