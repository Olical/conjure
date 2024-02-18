-- [nfnl] Compiled from fnl/conjure/client.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, config, dyn, fennel, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.dynamic"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["dyn"] = dyn
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local call = (_2amodule_2a).call
local current = (_2amodule_2a).current
local current_client_module_name = (_2amodule_2a)["current-client-module-name"]
local each_loaded_client = (_2amodule_2a)["each-loaded-client"]
local get = (_2amodule_2a).get
local multiple_states_3f = (_2amodule_2a)["multiple-states?"]
local new_state = (_2amodule_2a)["new-state"]
local optional_call = (_2amodule_2a)["optional-call"]
local schedule = (_2amodule_2a).schedule
local schedule_wrap = (_2amodule_2a)["schedule-wrap"]
local set_state_key_21 = (_2amodule_2a)["set-state-key!"]
local state_key = (_2amodule_2a)["state-key"]
local with_filetype = (_2amodule_2a)["with-filetype"]
local wrap = (_2amodule_2a).wrap
local a0 = (_2amodule_locals_2a).a
local config0 = (_2amodule_locals_2a).config
local dyn0 = (_2amodule_locals_2a).dyn
local extension = (_2amodule_locals_2a).extension
local fennel0 = (_2amodule_locals_2a).fennel
local filetype = (_2amodule_locals_2a).filetype
local load_module = (_2amodule_locals_2a)["load-module"]
local loaded = (_2amodule_locals_2a).loaded
local nvim0 = (_2amodule_locals_2a).nvim
local state = (_2amodule_locals_2a).state
local str0 = (_2amodule_locals_2a).str
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local state_key0
local function _1_()
  return "default"
end
state_key0 = ((_2amodule_2a)["state-key"] or dyn0.new(_1_))
do end (_2amodule_2a)["state-key"] = state_key0
do local _ = {nil, nil} end
local state0 = ((_2amodule_2a).state or {["state-key-set?"] = false})
do end (_2amodule_locals_2a)["state"] = state0
do local _ = {nil, nil} end
local function set_state_key_210(new_key)
  state0["state-key-set?"] = true
  local function _2_()
    return new_key
  end
  return dyn0["set-root!"](state_key0, _2_)
end
_2amodule_2a["set-state-key!"] = set_state_key_210
do local _ = {set_state_key_210, nil} end
local function multiple_states_3f0()
  return state0["state-key-set?"]
end
_2amodule_2a["multiple-states?"] = multiple_states_3f0
do local _ = {multiple_states_3f0, nil} end
local function new_state0(init_fn)
  local key__3estate = {}
  local function _3_(...)
    local key = state_key0()
    local state1 = a0.get(key__3estate, key)
    local _4_
    if (nil == state1) then
      local new_state1 = init_fn()
      a0.assoc(key__3estate, key, new_state1)
      _4_ = new_state1
    else
      _4_ = state1
    end
    return a0["get-in"](_4_, {...})
  end
  return _3_
end
_2amodule_2a["new-state"] = new_state0
do local _ = {new_state0, nil} end
local loaded0 = ((_2amodule_2a).loaded or {})
do end (_2amodule_locals_2a)["loaded"] = loaded0
do local _ = {nil, nil} end
local function load_module0(ft, name)
  local fnl = fennel0.impl()
  local ok_3f, result = nil, nil
  local function _7_()
    return require(name)
  end
  ok_3f, result = xpcall(_7_, fnl.traceback)
  if (ok_3f and a0["nil?"](a0.get(loaded0, name))) then
    a0.assoc(loaded0, name, {filetype = ft, ["module-name"] = name, module = result})
    if (result["on-load"] and not nvim0.wo.diff and config0["get-in"]({"client_on_load"})) then
      vim.schedule(result["on-load"])
    else
    end
  else
  end
  if ok_3f then
    return result
  else
    return error(result)
  end
end
_2amodule_locals_2a["load-module"] = load_module0
do local _ = {load_module0, nil} end
local filetype0
local function _11_()
  return nvim0.bo.filetype
end
filetype0 = dyn0.new(_11_)
do end (_2amodule_locals_2a)["filetype"] = filetype0
do local _ = {nil, nil} end
local extension0
local function _12_()
  return nvim0.fn.expand("%:e")
end
extension0 = dyn0.new(_12_)
do end (_2amodule_locals_2a)["extension"] = extension0
do local _ = {nil, nil} end
local function with_filetype0(ft, f, ...)
  local function _13_()
    return ft
  end
  local function _14_()
    return nil
  end
  return dyn0.bind({[filetype0] = _13_, [extension0] = _14_}, f, ...)
end
_2amodule_2a["with-filetype"] = with_filetype0
do local _ = {with_filetype0, nil} end
local function wrap0(f, ...)
  local opts = {[filetype0] = a0.constantly(filetype0()), [state_key0] = a0.constantly(state_key0())}
  local args = {...}
  local function _15_(...)
    if (0 ~= a0.count(args)) then
      return dyn0.bind(opts, f, unpack(args), ...)
    else
      return dyn0.bind(opts, f, ...)
    end
  end
  return _15_
end
_2amodule_2a["wrap"] = wrap0
do local _ = {wrap0, nil} end
local function schedule_wrap0(f, ...)
  return wrap0(vim.schedule_wrap(f), ...)
end
_2amodule_2a["schedule-wrap"] = schedule_wrap0
do local _ = {schedule_wrap0, nil} end
local function schedule0(f, ...)
  return vim.schedule(wrap0(f, ...))
end
_2amodule_2a["schedule"] = schedule0
do local _ = {schedule0, nil} end
local function current_client_module_name0()
  local result = {filetype = filetype0(), extension = extension0(), ["module-name"] = nil}
  do
    local fts
    if result.filetype then
      fts = str0.split(result.filetype, "%.")
    else
      fts = nil
    end
    if fts then
      for i = a0.count(fts), 1, -1 do
        local ft_part = fts[i]
        local module_name = config0["get-in"]({"filetype", ft_part})
        local suffixes = config0["get-in"]({"filetype_suffixes", ft_part})
        local function _18_(_241)
          return (result.extension == _241)
        end
        if (not result["module-name"] and module_name and (not suffixes or not result.extension or a0.some(_18_, suffixes))) then
          result["module-name"] = module_name
        else
        end
      end
    else
    end
  end
  return result
end
_2amodule_2a["current-client-module-name"] = current_client_module_name0
do local _ = {current_client_module_name0, nil} end
local function current0()
  local _let_21_ = current_client_module_name0()
  local module_name = _let_21_["module-name"]
  local filetype1 = _let_21_["filetype"]
  local extension1 = _let_21_["extension"]
  if module_name then
    return load_module0(filetype1, module_name)
  else
    return nil
  end
end
_2amodule_2a["current"] = current0
do local _ = {current0, nil} end
local function get0(...)
  return a0["get-in"](current0(), {...})
end
_2amodule_2a["get"] = get0
do local _ = {get0, nil} end
local function call0(fn_name, ...)
  local f = get0(fn_name)
  if f then
    return f(...)
  else
    return error(str0.join({"Conjure client '", a0.get(current_client_module_name0(), "module-name"), "' doesn't support function: ", fn_name}))
  end
end
_2amodule_2a["call"] = call0
do local _ = {call0, nil} end
local function optional_call0(fn_name, ...)
  local f = get0(fn_name)
  if f then
    return f(...)
  else
    return nil
  end
end
_2amodule_2a["optional-call"] = optional_call0
do local _ = {optional_call0, nil} end
local function each_loaded_client0(f)
  local function _27_(_25_)
    local _arg_26_ = _25_
    local filetype1 = _arg_26_["filetype"]
    return with_filetype0(filetype1, f)
  end
  return a0["run!"](_27_, a0.vals(loaded0))
end
_2amodule_2a["each-loaded-client"] = each_loaded_client0
do local _ = {each_loaded_client0, nil} end
return _2amodule_2a
