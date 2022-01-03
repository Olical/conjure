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
local a, client, config, log, mapping, nvim, stdio, str, text, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["_"] = _
local cfg = config["get-in-fn"]({"client", "lua", "neovim"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local buf_suffix = ".lua"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "-- "
_2amodule_2a["comment-prefix"] = comment_prefix
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function display(out, ret, err)
  local outs
  local function _2_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  local function _3_(_241)
    return ("" ~= _241)
  end
  outs = a.map(_2_, a.filter(_3_, str.split((out or ""), "\n")))
  local errs
  local function _4_(_241)
    return (comment_prefix .. "(err) " .. _241)
  end
  local function _5_(_241)
    return ("" ~= _241)
  end
  errs = a.map(_4_, a.filter(_5_, str.split((err or ""), "\n")))
  log.append(outs)
  log.append(errs)
  return log.append(str.split(vim.inspect(ret), "\n"))
end
_2amodule_locals_2a["display"] = display
local print_original = _G.print
_2amodule_locals_2a["print_original"] = print_original
local io_write_original = _G.io.write
_2amodule_locals_2a["io_write_original"] = io_write_original
CONJURE_NVIM_REDIRECTED = ""
local function redirect()
  local function _6_(...)
    CONJURE_NVIM_REDIRECTED = (CONJURE_NVIM_REDIRECTED .. str.join("\9", {...}) .. "\n")
    return nil
  end
  _G.print = _6_
  local function _7_(...)
    CONJURE_NVIM_REDIRECTED = (CONJURE_NVIM_REDIRECTED .. str.join({...}))
    return nil
  end
  _G.io.write = _7_
  return nil
end
_2amodule_locals_2a["redirect"] = redirect
local function end_redirect()
  _G.print = print_original
  _G.io.write = io_write_original
  local result = CONJURE_NVIM_REDIRECTED
  CONJURE_NVIM_REDIRECTED = ""
  return result
end
_2amodule_locals_2a["end-redirect"] = end_redirect
local function lua_try_compile(codes)
  local f, e = load(("return (" .. codes .. "\n)"))
  if not f then
    return load(codes)
  else
    return f, e
  end
end
_2amodule_locals_2a["lua-try-compile"] = lua_try_compile
local function lua_eval(codes)
  local f, e = lua_try_compile(codes)
  if f then
    redirect()
    local status, ret = pcall(f)
    if status then
      return end_redirect(), ret, ""
    else
      return end_redirect(), nil, ("Execution error: " .. ret)
    end
  else
    return "", nil, ("Compilation error: " .. e)
  end
end
_2amodule_locals_2a["lua-eval"] = lua_eval
local function eval_str(opts)
  local out, ret, err = lua_eval(opts.code)
  display(out, ret, err)
  if opts["on-result"] then
    local on_result = opts["on-result"]
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  redirect()
  local ret, err = loadfile(opts["file-path"])()
  display(end_redirect(), ret, err)
  if opts["on-result"] then
    local on_result = opts["on-result"]
    return opts["on-result"](vim.inspect(ret))
  else
    return nil
  end
end
_2amodule_2a["eval-file"] = eval_file