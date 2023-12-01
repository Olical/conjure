-- [nfnl] Compiled from fnl/conjure/client/rust/evcxr.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.client.rust.evcxr"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, client, config, log, nvim, promise, stdio, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["promise"] = promise
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local buf_suffix = ".rs"
_2amodule_2a["buf-suffix"] = buf_suffix
do local _ = {nil, nil} end
local comment_prefix = "// "
_2amodule_2a["comment-prefix"] = comment_prefix
do local _ = {nil, nil} end
config.merge({client = {rust = {evcxr = {command = "evcxr", prompt_pattern = ">> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {rust = {evcxr = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "rust", "evcxr"})
do end (_2amodule_locals_2a)["cfg"] = cfg
do local _ = {nil, nil} end
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
do local _ = {nil, nil} end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
do local _ = {with_repl_or_warn, nil} end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return log.append({status})
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
do local _ = {display_repl_status, nil} end
local function display_result(msg)
  local function _5_(_241)
    return (comment_prefix .. _241)
  end
  return log.append(a.map(_5_, msg))
end
_2amodule_locals_2a["display-result"] = display_result
do local _ = {display_result, nil} end
local function format_msg(msg)
  local function _6_(_241)
    return not ("()" == _241)
  end
  local function _7_(_241)
    return not ("" == _241)
  end
  return a.filter(_6_, a.filter(_7_, str.split(msg, "\n")))
end
_2amodule_locals_2a["format-msg"] = format_msg
do local _ = {format_msg, nil} end
local function unbatch(msgs)
  local function _8_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_8_, msgs))
end
_2amodule_locals_2a["unbatch"] = unbatch
do local _ = {unbatch, nil} end
local function prep_code(s)
  return (s .. "\n")
end
_2amodule_locals_2a["prep-code"] = prep_code
do local _ = {prep_code, nil} end
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
_2amodule_2a["stop"] = stop
do local _ = {stop, nil} end
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _10_()
      display_repl_status("started")
      local function _11_(repl)
        local function _12_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code(":help"), _12_, {["batch?"] = true})
      end
      return with_repl_or_warn(_11_)
    end
    local function _13_(err)
      log.append({"error"})
      return display_repl_status(err)
    end
    local function _14_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(comment_prefix .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(comment_prefix .. "process exited with signal " .. signal)})
      else
      end
      return stop()
    end
    local function _17_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _10_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
_2amodule_2a["start"] = start
do local _ = {start, nil} end
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
do local _ = {on_load, nil} end
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
do local _ = {on_exit, nil} end
local function interrupt()
  local function _19_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_19_)
end
_2amodule_2a["interrupt"] = interrupt
do local _ = {interrupt, nil} end
local function eval_str(opts)
  local function _20_(repl)
    local function _21_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _21_, {["batch?"] = true})
  end
  return with_repl_or_warn(_20_)
end
_2amodule_2a["eval-str"] = eval_str
do local _ = {eval_str, nil} end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
do local _ = {eval_file, nil} end
return _2amodule_2a
