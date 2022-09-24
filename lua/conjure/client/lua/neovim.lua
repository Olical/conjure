local _2afile_2a = "fnl/conjure/client/lua/neovim.fnl"
local _2amodule_name_2a = "conjure.client.lua.neovim"
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
local buf_suffix = ".lua"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "-- "
_2amodule_2a["comment-prefix"] = comment_prefix
config.merge({client = {lua = {neovim = {mapping = {reset_env = "rr", reset_all_envs = "ra"}, persistent = "debug"}}}})
local cfg = config["get-in-fn"]({"client", "lua", "neovim"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local repls = ((_2amodule_2a).repls or {})
do end (_2amodule_locals_2a)["repls"] = repls
local function reset_env(filename)
  local filename0 = (filename or fs["localise-path"](extract["file-path"]()))
  do end (repls)[filename0] = nil
  return log.append({(comment_prefix .. "Reset environment for " .. filename0)}, {["break?"] = true})
end
_2amodule_2a["reset-env"] = reset_env
local function reset_all_envs()
  local function _1_(filename)
    repls[filename] = nil
    return nil
  end
  a["run!"](_1_, a.keys(repls))
  return log.append({(comment_prefix .. "Reset all environments")}, {["break?"] = true})
end
_2amodule_2a["reset-all-envs"] = reset_all_envs
local function on_filetype()
  local function _2_()
    return reset_env()
  end
  mapping.buf("LuaResetEnv", cfg({"mapping", "reset_env"}), _2_)
  local function _3_()
    return reset_all_envs()
  end
  return mapping.buf("LuaResetAllEnvs", cfg({"mapping", "reset_all_envs"}), _3_)
end
_2amodule_2a["on-filetype"] = on_filetype
local function display(out, ret, err)
  local outs
  local function _4_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  local function _5_(_241)
    return ("" ~= _241)
  end
  outs = a.map(_4_, a.filter(_5_, str.split((out or ""), "\n")))
  local errs
  local function _6_(_241)
    return (comment_prefix .. "(err) " .. _241)
  end
  local function _7_(_241)
    return ("" ~= _241)
  end
  errs = a.map(_6_, a.filter(_7_, str.split((err or ""), "\n")))
  log.append(outs)
  log.append(errs)
  return log.append(str.split(("res = " .. vim.inspect(ret)), "\n"))
end
_2amodule_locals_2a["display"] = display
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
_2amodule_locals_2a["lua-compile"] = lua_compile
local function default_env()
  local base = setmetatable({["REDIRECTED-OUTPUT"] = "", io = setmetatable({}, {__index = _G.io})}, {__index = _G})
  local print_redirected
  local function _10_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str.join("\9", {...}) .. "\n")
    return nil
  end
  print_redirected = _10_
  local io_write_redirected
  local function _11_(...)
    base["REDIRECTED-OUTPUT"] = (base["REDIRECTED-OUTPUT"] .. str.join({...}))
    return nil
  end
  io_write_redirected = _11_
  local io_read_redirected
  local function _12_()
    return ((extract.prompt("Input required: ") or "") .. "\n")
  end
  io_read_redirected = _12_
  base["print"] = print_redirected
  base.io["write"] = io_write_redirected
  base.io["read"] = io_read_redirected
  return base
end
_2amodule_2a["default-env"] = default_env
local function pcall_default(f)
  local env = default_env()
  setfenv(f, env)
  local status, ret = pcall(f)
  return status, ret, env["REDIRECTED-OUTPUT"]
end
_2amodule_locals_2a["pcall-default"] = pcall_default
local function pcall_persistent_debug(file, f)
  repls[file] = (repls[file] or {})
  do end (repls[file])["env"] = (repls[file].env or default_env())
  do end (repls[file].env)["REDIRECTED-OUTPUT"] = ""
  setfenv(f, repls[file].env)
  local collect_env
  local function _13_(_0, _1)
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
  collect_env = _13_
  debug.sethook(collect_env, "r")
  local status, ret = pcall(f)
  return status, ret, repls[file].env["REDIRECTED-OUTPUT"]
end
_2amodule_locals_2a["pcall-persistent-debug"] = pcall_persistent_debug
local function lua_eval(opts)
  local f, e = lua_compile(opts)
  if f then
    local pcall_custom
    do
      local _15_ = cfg({"persistent"})
      if (_15_ == "debug") then
        local _16_ = opts["file-path"]
        local function _17_(...)
          return pcall_persistent_debug(_16_, ...)
        end
        pcall_custom = _17_
      elseif true then
        local _0 = _15_
        pcall_custom = pcall_default
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
_2amodule_locals_2a["lua-eval"] = lua_eval
local function eval_str(opts)
  local out, ret, err = lua_eval(opts)
  display(out, ret, err)
  if opts["on-result"] then
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
_2amodule_2a["eval-str"] = eval_str
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
_2amodule_2a["eval-file"] = eval_file
return _2amodule_2a