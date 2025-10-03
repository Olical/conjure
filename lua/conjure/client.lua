-- [nfnl] fnl/conjure/client.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local fennel = autoload("conjure.nfnl.fennel")
local str = autoload("conjure.nfnl.string")
local config = autoload("conjure.config")
local dyn = autoload("conjure.dynamic")
local vim = _G.vim
local M = define("conjure.client")
local or_2_ = M["state-key"]
if not or_2_ then
  local function _3_()
    return "default"
  end
  or_2_ = dyn.new(_3_)
end
M["state-key"] = or_2_
M.state = (M.state or {["state-key-set?"] = false})
M["set-state-key!"] = function(new_key)
  M.state["state-key-set?"] = true
  local function _4_()
    return new_key
  end
  return dyn["set-root!"](M["state-key"], _4_)
end
M["multiple-states?"] = function()
  return M.state["state-key-set?"]
end
M["new-state"] = function(init_fn)
  local key__3estate = {}
  local function _5_(...)
    local key = M["state-key"]()
    local state = core.get(key__3estate, key)
    local _6_
    if (nil == state) then
      local new_state = init_fn()
      core.assoc(key__3estate, key, new_state)
      _6_ = new_state
    else
      _6_ = state
    end
    return core["get-in"](_6_, {...})
  end
  return _5_
end
local loaded = {}
local function load_module(ft, name)
  local ok_3f, result = nil, nil
  local function _9_()
    return require(name)
  end
  ok_3f, result = xpcall(_9_, fennel.traceback)
  if (ok_3f and core["nil?"](core.get(loaded, name))) then
    core.assoc(loaded, name, {filetype = ft, ["module-name"] = name, module = result})
    if (result["on-load"] and not vim.wo.diff and config["get-in"]({"client_on_load"})) then
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
local function _13_()
  return vim.bo.filetype
end
filetype = dyn.new(_13_)
local extension
local function _14_()
  return vim.fn.expand("%:e")
end
extension = dyn.new(_14_)
M["with-filetype"] = function(ft, f, ...)
  local function _15_()
    return ft
  end
  local function _16_()
  end
  return dyn.bind({[filetype] = _15_, [extension] = _16_}, f, ...)
end
M.wrap = function(f, ...)
  local opts = {[filetype] = core.constantly(filetype()), [M["state-key"]] = core.constantly(M["state-key"]())}
  local args = {...}
  local function _17_(...)
    if (0 ~= core.count(args)) then
      return dyn.bind(opts, f, unpack(core.concat(args, {...})))
    else
      return dyn.bind(opts, f, ...)
    end
  end
  return _17_
end
M["schedule-wrap"] = function(f, ...)
  return M.wrap(vim.schedule_wrap(f), ...)
end
M.schedule = function(f, ...)
  return vim.schedule(M.wrap(f, ...))
end
M["current-client-module-name"] = function()
  local result = {filetype = filetype(), extension = extension(), ["module-name"] = nil}
  do
    local fts
    if result.filetype then
      fts = str.split(result.filetype, "%.")
    else
      fts = nil
    end
    if fts then
      for i = core.count(fts), 1, -1 do
        local ft_part = fts[i]
        local module_name = config["get-in"]({"filetype", ft_part})
        local suffixes = config["get-in"]({"filetype_suffixes", ft_part})
        local and_20_ = not result["module-name"] and module_name
        if and_20_ then
          local or_21_ = not suffixes or not result.extension
          if not or_21_ then
            local function _22_(_241)
              return (result.extension == _241)
            end
            or_21_ = core.some(_22_, suffixes)
          end
          and_20_ = or_21_
        end
        if and_20_ then
          result["module-name"] = module_name
        else
        end
      end
    else
    end
  end
  return result
end
M.current = function()
  local _let_25_ = M["current-client-module-name"]()
  local module_name = _let_25_["module-name"]
  local filetype0 = _let_25_["filetype"]
  local _extension = _let_25_["_extension"]
  if module_name then
    return load_module(filetype0, module_name)
  else
    return nil
  end
end
M.get = function(...)
  return core["get-in"](M.current(), {...})
end
M.call = function(fn_name, ...)
  local f = M.get(fn_name)
  if f then
    return f(...)
  elseif M.current() then
    return error(str.join({"Conjure client '", core.get(M["current-client-module-name"](), "module-name"), "' doesn't support function: ", fn_name}))
  else
    return error("No Conjure client configured for the current file type.")
  end
end
M["optional-call"] = function(fn_name, ...)
  local f = M.get(fn_name)
  if f then
    return f(...)
  else
    return nil
  end
end
M["each-loaded-client"] = function(f)
  local function _30_(_29_)
    local filetype0 = _29_["filetype"]
    return M["with-filetype"](filetype0, f)
  end
  return core["run!"](_30_, core.vals(loaded))
end
return M
