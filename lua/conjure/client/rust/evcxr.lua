-- [nfnl] Compiled from fnl/conjure/client/rust/evcxr.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local promise = autoload("conjure.promise")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local log = autoload("conjure.log")
local config = autoload("conjure.config")
local client = autoload("conjure.client")
local buf_suffix = ".rs"
local comment_prefix = "// "
config.merge({client = {rust = {evcxr = {command = "evcxr", prompt_pattern = ">> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {rust = {evcxr = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "rust", "evcxr"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return log.append({status})
  end
end
local function display_result(msg)
  local function _6_(_241)
    return (comment_prefix .. _241)
  end
  return log.append(a.map(_6_, msg))
end
local function format_msg(msg)
  local function _7_(_241)
    return not ("()" == _241)
  end
  local function _8_(_241)
    return not ("" == _241)
  end
  return a.filter(_7_, a.filter(_8_, str.split(msg, "\n")))
end
local function unbatch(msgs)
  local function _9_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_9_, msgs))
end
local function prep_code(s)
  return (s .. "\n")
end
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
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _11_()
      display_repl_status("started")
      local function _12_(repl)
        local function _13_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code(":help"), _13_, {["batch?"] = true})
      end
      return with_repl_or_warn(_12_)
    end
    local function _14_(err)
      log.append({"error"})
      return display_repl_status(err)
    end
    local function _15_(code, signal)
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
    local function _18_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _11_, ["on-error"] = _14_, ["on-exit"] = _15_, ["on-stray-output"] = _18_}))
  end
end
local function on_load()
  return start()
end
local function on_exit()
  return stop()
end
local function interrupt()
  local function _20_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_20_)
end
local function eval_str(opts)
  local function _21_(repl)
    local function _22_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _22_, {["batch?"] = true})
  end
  return with_repl_or_warn(_21_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, stop = stop, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, interrupt = interrupt, ["eval-str"] = eval_str, ["eval-file"] = eval_file}
