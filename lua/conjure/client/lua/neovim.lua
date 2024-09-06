-- [nfnl] Compiled from fnl/conjure/client/lua/neovim.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local fs = autoload("conjure.fs")
local extract = autoload("conjure.extract")
local buf_suffix = ".lua"
local comment_prefix = "-- "
local function form_node_3f(node)
  return (("function_call" == node:type()) or ("function_definition" == node:type()) or ("function_declaration" == node:type()) or ("local_declaration" == node:type()) or ("variable_declaration" == node:type()) or ("if_statement" == node:type()))
end
config.merge({client = {lua = {neovim = {persistent = "debug"}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {lua = {neovim = {mapping = {reset_env = "rr", reset_all_envs = "ra"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "lua", "neovim"})
local repls = {}
local function reset_env(filename)
  local filename0 = (filename or fs["localise-path"](extract["file-path"]()))
  repls[filename0] = nil
  return log.append({(comment_prefix .. "Reset environment for " .. filename0)}, {["break?"] = true})
end
local function reset_all_envs()
  local function _3_(filename)
    repls[filename] = nil
    return nil
  end
  a["run!"](_3_, a.keys(repls))
  return log.append({(comment_prefix .. "Reset all environments")}, {["break?"] = true})
end
local function on_filetype()
  local function _4_()
    return reset_env()
  end
  mapping.buf("LuaResetEnv", cfg({"mapping", "reset_env"}), _4_)
  local function _5_()
    return reset_all_envs()
  end
  return mapping.buf("LuaResetAllEnvs", cfg({"mapping", "reset_all_envs"}), _5_)
end
local function display(out, ret, err)
  local outs
  local function _6_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  local function _7_(_241)
    return ("" ~= _241)
  end
  outs = a.map(_6_, a.filter(_7_, str.split((out or ""), "\n")))
  local errs
  local function _8_(_241)
    return (comment_prefix .. "(err) " .. _241)
  end
  local function _9_(_241)
    return ("" ~= _241)
  end
  errs = a.map(_8_, a.filter(_9_, str.split((err or ""), "\n")))
  log.append(outs)
  log.append(errs)
  return log.append(str.split(("res = " .. vim.inspect(ret)), "\n"))
end
local function lua_compile(opts)
  if (opts.origin == "file") then
    return loadfile(opts["file-path"])
  else
    local f, e = load(("return (" .. opts.code .. "\n)"))
    if f then
      return f, e
    else
      return load(opts.code)
    end
  end
end
local function default_env()
  local base = setmetatable({["REDIRECTED-OUTPUT"] = "", io = setmetatable({}, {__index = _G.io})}, {__index = _G})
  local print_redirected
  local function _12_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str.join("\t", {...}) .. "\n")
    return nil
  end
  print_redirected = _12_
  local io_write_redirected
  local function _13_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str.join({...}))
    return nil
  end
  io_write_redirected = _13_
  local io_read_redirected
  local function _14_()
    return ((extract.prompt("Input required: ") or "") .. "\n")
  end
  io_read_redirected = _14_
  base["print"] = print_redirected
  base.io["write"] = io_write_redirected
  base.io["read"] = io_read_redirected
  return base
end
local function pcall_default(f)
  local env = default_env()
  setfenv(f, env)
  local status, ret = pcall(f)
  return status, ret, env["REDIRECTED-OUTPUT"]
end
local function pcall_persistent_debug(file, f)
  repls[file] = (repls[file] or {})
  repls[file]["env"] = (repls[file].env or default_env())
  repls[file].env["REDIRECTED-OUTPUT"] = ""
  setfenv(f, repls[file].env)
  local collect_env
  local function _15_(_, _0)
    debug.sethook()
    local i = 1
    local n = true
    local v = nil
    while n do
      n, v = debug.getlocal(2, i)
      if n then
        repls[file].env[n] = v
        i = (i + 1)
      else
      end
    end
    return nil
  end
  collect_env = _15_
  debug.sethook(collect_env, "r")
  local status, ret = pcall(f)
  return status, ret, repls[file].env["REDIRECTED-OUTPUT"]
end
local function lua_eval(opts)
  local f, e = lua_compile(opts)
  if f then
    local pcall_custom
    do
      local _17_ = cfg({"persistent"})
      if (_17_ == "debug") then
        local _18_ = opts["file-path"]
        local function _19_(...)
          return pcall_persistent_debug(_18_, ...)
        end
        pcall_custom = _19_
      else
        local _ = _17_
        pcall_custom = pcall_default
      end
    end
    local status, ret, out = pcall_custom(f)
    if status then
      return out, ret, ""
    else
      return out, nil, ("Execution error: " .. ret)
    end
  else
    return "", nil, ("Compilation error: " .. e)
  end
end
local function eval_str(opts)
  local out, ret, err = lua_eval(opts)
  display(out, ret, err)
  if opts["on-result"] then
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
local function eval_file(opts)
  reset_env(opts["file-path"])
  local out, ret, err = lua_eval(opts)
  display(out, ret, err)
  if opts["on-result"] then
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["reset-env"] = reset_env, ["reset-all-envs"] = reset_all_envs, ["on-filetype"] = on_filetype, ["default-env"] = default_env, ["eval-str"] = eval_str, ["eval-file"] = eval_file}
