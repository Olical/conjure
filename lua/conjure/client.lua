-- [nfnl] Compiled from fnl/conjure/client.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local fennel = autoload("conjure.aniseed.fennel")
local str = autoload("conjure.aniseed.string")
local config = autoload("conjure.config")
local dyn = autoload("conjure.dynamic")
local state_key
local function _2_()
  return "default"
end
state_key = dyn.new(_2_)
local state = {["state-key-set?"] = false}
local function set_state_key_21(new_key)
  state["state-key-set?"] = true
  local function _3_()
    return new_key
  end
  return dyn["set-root!"](state_key, _3_)
end
local function multiple_states_3f()
  return state["state-key-set?"]
end
local function new_state(init_fn)
  local key__3estate = {}
  local function _4_(...)
    local key = state_key()
    local state0 = a.get(key__3estate, key)
    local _5_
    if (nil == state0) then
      local new_state0 = init_fn()
      a.assoc(key__3estate, key, new_state0)
      _5_ = new_state0
    else
      _5_ = state0
    end
    return a["get-in"](_5_, {...})
  end
  return _4_
end
local loaded = {}
local function load_module(ft, name)
  local fnl = fennel.impl()
  local ok_3f, result = nil, nil
  local function _8_()
    return require(name)
  end
  ok_3f, result = xpcall(_8_, fnl.traceback)
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
local filetype
local function _12_()
  return nvim.bo.filetype
end
filetype = dyn.new(_12_)
local extension
local function _13_()
  return nvim.fn.expand("%:e")
end
extension = dyn.new(_13_)
local function with_filetype(ft, f, ...)
  local function _14_()
    return ft
  end
  local function _15_()
  end
  return dyn.bind({[filetype] = _14_, [extension] = _15_}, f, ...)
end
local function wrap(f, ...)
  local opts = {[filetype] = a.constantly(filetype()), [state_key] = a.constantly(state_key())}
  local args = {...}
  local function _16_(...)
    if (0 ~= a.count(args)) then
      return dyn.bind(opts, f, unpack(args), ...)
    else
      return dyn.bind(opts, f, ...)
    end
  end
  return _16_
end
local function schedule_wrap(f, ...)
  return wrap(vim.schedule_wrap(f), ...)
end
local function schedule(f, ...)
  return vim.schedule(wrap(f, ...))
end
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
        local and_19_ = not result["module-name"] and module_name
        if and_19_ then
          local or_20_ = not suffixes or not result.extension
          if not or_20_ then
            local function _21_(_241)
              return (result.extension == _241)
            end
            or_20_ = a.some(_21_, suffixes)
          end
          and_19_ = or_20_
        end
        if and_19_ then
          result["module-name"] = module_name
        else
        end
      end
    else
    end
  end
  return result
end
local function current()
  local _let_24_ = current_client_module_name()
  local module_name = _let_24_["module-name"]
  local filetype0 = _let_24_["filetype"]
  local extension0 = _let_24_["extension"]
  if module_name then
    return load_module(filetype0, module_name)
  else
    return nil
  end
end
local function get(...)
  return a["get-in"](current(), {...})
end
local function call(fn_name, ...)
  local f = get(fn_name)
  if f then
    return f(...)
  else
    return error(str.join({"Conjure client '", a.get(current_client_module_name(), "module-name"), "' doesn't support function: ", fn_name}))
  end
end
local function optional_call(fn_name, ...)
  local f = get(fn_name)
  if f then
    return f(...)
  else
    return nil
  end
end
local function each_loaded_client(f)
  local function _29_(_28_)
    local filetype0 = _28_["filetype"]
    return with_filetype(filetype0, f)
  end
  return a["run!"](_29_, a.vals(loaded))
end
return {["state-key"] = state_key, ["set-state-key!"] = set_state_key_21, ["multiple-states?"] = multiple_states_3f, ["new-state"] = new_state, ["with-filetype"] = with_filetype, wrap = wrap, ["schedule-wrap"] = schedule_wrap, schedule = schedule, ["current-client-module-name"] = current_client_module_name, current = current, get = get, call = call, ["optional-call"] = optional_call, ["each-loaded-client"] = each_loaded_client}
