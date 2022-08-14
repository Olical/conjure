local _2afile_2a = "fnl/conjure/client.fnl"
local _2amodule_name_2a = "conjure.client"
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
local a, config, dyn, fennel, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.dynamic"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["dyn"] = dyn
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local state_key
local function _1_()
  return "default"
end
state_key = ((_2amodule_2a)["state-key"] or dyn.new(_1_))
do end (_2amodule_2a)["state-key"] = state_key
local state = ((_2amodule_2a).state or {["state-key-set?"] = false})
do end (_2amodule_locals_2a)["state"] = state
local function set_state_key_21(new_key)
  state["state-key-set?"] = true
  local function _2_()
    return new_key
  end
  return dyn["set-root!"](state_key, _2_)
end
_2amodule_2a["set-state-key!"] = set_state_key_21
local function multiple_states_3f()
  return state["state-key-set?"]
end
_2amodule_2a["multiple-states?"] = multiple_states_3f
local function new_state(init_fn)
  local key__3estate = {}
  local function _3_(...)
    local key = state_key()
    local state0 = a.get(key__3estate, key)
    local _4_
    if (nil == state0) then
      local new_state0 = init_fn()
      a.assoc(key__3estate, key, new_state0)
      _4_ = new_state0
    else
      _4_ = state0
    end
    return a["get-in"](_4_, {...})
  end
  return _3_
end
_2amodule_2a["new-state"] = new_state
local loaded = ((_2amodule_2a).loaded or {})
do end (_2amodule_locals_2a)["loaded"] = loaded
local function load_module(ft, name)
  local fnl = fennel.impl()
  local ok_3f, result = nil, nil
  local function _7_()
    return require(name)
  end
  ok_3f, result = xpcall(_7_, fnl.traceback)
  if (ok_3f and a["nil?"](a.get(loaded, name))) then
    a.assoc(loaded, name, {filetype = ft, ["module-name"] = name, module = result})
    if (result["on-load"] and not nvim.wo.diff and config["get-in"]({"client_on_load"})) then
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
_2amodule_locals_2a["load-module"] = load_module
local filetype
local function _11_()
  return nvim.bo.filetype
end
filetype = dyn.new(_11_)
do end (_2amodule_locals_2a)["filetype"] = filetype
local extension
local function _12_()
  return nvim.fn.expand("%:e")
end
extension = dyn.new(_12_)
do end (_2amodule_locals_2a)["extension"] = extension
local function with_filetype(ft, f, ...)
  local function _13_()
    return ft
  end
  local function _14_()
    return nil
  end
  return dyn.bind({[filetype] = _13_, [extension] = _14_}, f, ...)
end
_2amodule_2a["with-filetype"] = with_filetype
local function wrap(f, ...)
  local opts = {[filetype] = a.constantly(filetype()), [state_key] = a.constantly(state_key())}
  local args = {...}
  local function _15_(...)
    if (0 ~= a.count(args)) then
      return dyn.bind(opts, f, unpack(args), ...)
    else
      return dyn.bind(opts, f, ...)
    end
  end
  return _15_
end
_2amodule_2a["wrap"] = wrap
local function schedule_wrap(f, ...)
  return wrap(vim.schedule_wrap(f), ...)
end
_2amodule_2a["schedule-wrap"] = schedule_wrap
local function schedule(f, ...)
  return vim.schedule(wrap(f, ...))
end
_2amodule_2a["schedule"] = schedule
local function current_client_module_name()
  local result = {filetype = filetype(), extension = extension(), ["module-name"] = nil}
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
        local function _18_(_241)
          return (result.extension == _241)
        end
        if (not result["module-name"] and module_name and (not suffixes or not result.extension or a.some(_18_, suffixes))) then
          result["module-name"] = module_name
        else
        end
      end
    else
    end
  end
  return result
end
_2amodule_locals_2a["current-client-module-name"] = current_client_module_name
local function current()
  local _let_21_ = current_client_module_name()
  local module_name = _let_21_["module-name"]
  local filetype0 = _let_21_["filetype"]
  local extension0 = _let_21_["extension"]
  if module_name then
    return load_module(filetype0, module_name)
  else
    return nil
  end
end
_2amodule_2a["current"] = current
local function get(...)
  return a["get-in"](current(), {...})
end
_2amodule_2a["get"] = get
local function call(fn_name, ...)
  local f = get(fn_name)
  if f then
    return f(...)
  else
    return error(str.join({"Conjure client '", a.get(current_client_module_name(), "module-name"), "' doesn't support function: ", fn_name}))
  end
end
_2amodule_2a["call"] = call
local function optional_call(fn_name, ...)
  local f = get(fn_name)
  if f then
    return f(...)
  else
    return nil
  end
end
_2amodule_2a["optional-call"] = optional_call
local function each_loaded_client(f)
  local function _27_(_25_)
    local _arg_26_ = _25_
    local filetype0 = _arg_26_["filetype"]
    return with_filetype(filetype0, f)
  end
  return a["run!"](_27_, a.vals(loaded))
end
_2amodule_2a["each-loaded-client"] = each_loaded_client
return _2amodule_2a