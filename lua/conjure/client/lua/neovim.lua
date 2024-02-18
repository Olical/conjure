-- [nfnl] Compiled from fnl/conjure/client/lua/neovim.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.lua.neovim"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, client, config, extract, fs, log, mapping, nvim, stdio, str, text, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["_"] = _
local buf_suffix = (_2amodule_2a)["buf-suffix"]
local comment_prefix = (_2amodule_2a)["comment-prefix"]
local default_env = (_2amodule_2a)["default-env"]
local eval_file = (_2amodule_2a)["eval-file"]
local eval_str = (_2amodule_2a)["eval-str"]
local form_node_3f = (_2amodule_2a)["form-node?"]
local on_filetype = (_2amodule_2a)["on-filetype"]
local reset_all_envs = (_2amodule_2a)["reset-all-envs"]
local reset_env = (_2amodule_2a)["reset-env"]
local a0 = (_2amodule_locals_2a).a
local cfg = (_2amodule_locals_2a).cfg
local client0 = (_2amodule_locals_2a).client
local config0 = (_2amodule_locals_2a).config
local display = (_2amodule_locals_2a).display
local extract0 = (_2amodule_locals_2a).extract
local fs0 = (_2amodule_locals_2a).fs
local log0 = (_2amodule_locals_2a).log
local lua_compile = (_2amodule_locals_2a)["lua-compile"]
local lua_eval = (_2amodule_locals_2a)["lua-eval"]
local mapping0 = (_2amodule_locals_2a).mapping
local nvim0 = (_2amodule_locals_2a).nvim
local pcall_default = (_2amodule_locals_2a)["pcall-default"]
local pcall_persistent_debug = (_2amodule_locals_2a)["pcall-persistent-debug"]
local repls = (_2amodule_locals_2a).repls
local stdio0 = (_2amodule_locals_2a).stdio
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local buf_suffix0 = ".lua"
_2amodule_2a["buf-suffix"] = buf_suffix0
do local _ = {nil, nil} end
local comment_prefix0 = "-- "
_2amodule_2a["comment-prefix"] = comment_prefix0
do local _ = {nil, nil} end
local function form_node_3f0(node)
  return (("function_call" == node:type()) or ("function_definition" == node:type()) or ("function_declaration" == node:type()) or ("local_declaration" == node:type()) or ("variable_declaration" == node:type()) or ("if_statement" == node:type()))
end
_2amodule_2a["form-node?"] = form_node_3f0
do local _ = {form_node_3f0, nil} end
config0.merge({client = {lua = {neovim = {persistent = "debug"}}}})
if config0["get-in"]({"mapping", "enable_defaults"}) then
  config0.merge({client = {lua = {neovim = {mapping = {reset_env = "rr", reset_all_envs = "ra"}}}}})
else
end
local cfg0 = config0["get-in-fn"]({"client", "lua", "neovim"})
do end (_2amodule_locals_2a)["cfg"] = cfg0
do local _ = {nil, nil} end
local repls0 = ((_2amodule_2a).repls or {})
do end (_2amodule_locals_2a)["repls"] = repls0
do local _ = {nil, nil} end
local function reset_env0(filename)
  local filename0 = (filename or fs0["localise-path"](extract0["file-path"]()))
  do end (repls0)[filename0] = nil
  return log0.append({(comment_prefix0 .. "Reset environment for " .. filename0)}, {["break?"] = true})
end
_2amodule_2a["reset-env"] = reset_env0
do local _ = {reset_env0, nil} end
local function reset_all_envs0()
  local function _2_(filename)
    repls0[filename] = nil
    return nil
  end
  a0["run!"](_2_, a0.keys(repls0))
  return log0.append({(comment_prefix0 .. "Reset all environments")}, {["break?"] = true})
end
_2amodule_2a["reset-all-envs"] = reset_all_envs0
do local _ = {reset_all_envs0, nil} end
local function on_filetype0()
  local function _3_()
    return reset_env0()
  end
  mapping0.buf("LuaResetEnv", cfg0({"mapping", "reset_env"}), _3_)
  local function _4_()
    return reset_all_envs0()
  end
  return mapping0.buf("LuaResetAllEnvs", cfg0({"mapping", "reset_all_envs"}), _4_)
end
_2amodule_2a["on-filetype"] = on_filetype0
do local _ = {on_filetype0, nil} end
local function display0(out, ret, err)
  local outs
  local function _5_(_241)
    return (comment_prefix0 .. "(out) " .. _241)
  end
  local function _6_(_241)
    return ("" ~= _241)
  end
  outs = a0.map(_5_, a0.filter(_6_, str0.split((out or ""), "\n")))
  local errs
  local function _7_(_241)
    return (comment_prefix0 .. "(err) " .. _241)
  end
  local function _8_(_241)
    return ("" ~= _241)
  end
  errs = a0.map(_7_, a0.filter(_8_, str0.split((err or ""), "\n")))
  log0.append(outs)
  log0.append(errs)
  return log0.append(str0.split(("res = " .. vim.inspect(ret)), "\n"))
end
_2amodule_locals_2a["display"] = display0
do local _ = {display0, nil} end
local function lua_compile0(opts)
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
_2amodule_locals_2a["lua-compile"] = lua_compile0
do local _ = {lua_compile0, nil} end
local function default_env0()
  local base = setmetatable({["REDIRECTED-OUTPUT"] = "", io = setmetatable({}, {__index = _G.io})}, {__index = _G})
  local print_redirected
  local function _11_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str0.join("\9", {...}) .. "\n")
    return nil
  end
  print_redirected = _11_
  local io_write_redirected
  local function _12_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str0.join({...}))
    return nil
  end
  io_write_redirected = _12_
  local io_read_redirected
  local function _13_()
    return ((extract0.prompt("Input required: ") or "") .. "\n")
  end
  io_read_redirected = _13_
  base["print"] = print_redirected
  base.io["write"] = io_write_redirected
  base.io["read"] = io_read_redirected
  return base
end
_2amodule_2a["default-env"] = default_env0
do local _ = {default_env0, nil} end
local function pcall_default0(f)
  local env = default_env0()
  setfenv(f, env)
  local status, ret = pcall(f)
  return status, ret, env["REDIRECTED-OUTPUT"]
end
_2amodule_locals_2a["pcall-default"] = pcall_default0
do local _ = {pcall_default0, nil} end
local function pcall_persistent_debug0(file, f)
  repls0[file] = ((repls0)[file] or {})
  do end ((repls0)[file])["env"] = ((repls0)[file].env or default_env0())
  do end ((repls0)[file].env)["REDIRECTED-OUTPUT"] = ""
  setfenv(f, (repls0)[file].env)
  local collect_env
  local function _14_(_0, _1)
    debug.sethook()
    local i = 1
    local n = true
    local v = nil
    while n do
      n, v = debug.getlocal(2, i)
      if n then
        (repls0)[file].env[n] = v
        i = (i + 1)
      else
      end
    end
    return nil
  end
  collect_env = _14_
  debug.sethook(collect_env, "r")
  local status, ret = pcall(f)
  return status, ret, (repls0)[file].env["REDIRECTED-OUTPUT"]
end
_2amodule_locals_2a["pcall-persistent-debug"] = pcall_persistent_debug0
do local _ = {pcall_persistent_debug0, nil} end
local function lua_eval0(opts)
  local f, e = lua_compile0(opts)
  if f then
    local pcall_custom
    do
      local _16_ = cfg0({"persistent"})
      if (_16_ == "debug") then
        local _17_ = opts["file-path"]
        local function _18_(...)
          return pcall_persistent_debug0(_17_, ...)
        end
        pcall_custom = _18_
      elseif true then
        local _0 = _16_
        pcall_custom = pcall_default0
      else
        pcall_custom = nil
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
_2amodule_locals_2a["lua-eval"] = lua_eval0
do local _ = {lua_eval0, nil} end
local function eval_str0(opts)
  local out, ret, err = lua_eval0(opts)
  display0(out, ret, err)
  if opts["on-result"] then
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
_2amodule_2a["eval-str"] = eval_str0
do local _ = {eval_str0, nil} end
local function eval_file0(opts)
  reset_env0(opts["file-path"])
  local out, ret, err = lua_eval0(opts)
  display0(out, ret, err)
  if opts["on-result"] then
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
_2amodule_2a["eval-file"] = eval_file0
do local _ = {eval_file0, nil} end
return _2amodule_2a
