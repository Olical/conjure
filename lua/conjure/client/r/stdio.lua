-- [nfnl] fnl/conjure/client/r/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.r.stdio")
config.merge({client = {r = {stdio = {command = "R --vanilla --interactive --quiet", prompt_pattern = "> ", ["delay-stderr-ms"] = 16}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {r = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "r", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".r"
M["comment-prefix"] = "# "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, _)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
M.unbatch = function(msgs)
  local function _5_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return {out = str.join("", core.map(_5_, msgs))}
end
M["format-msg"] = function(msg)
  local function _6_(_241)
    return not str["blank?"](_241)
  end
  local function _7_(line)
    if not cfg({"value_prefix_pattern"}) then
      return line
    elseif string.match(line, cfg({"value_prefix_pattern"})) then
      return string.gsub(line, cfg({"value_prefix_pattern"}), "")
    else
      return (M["comment-prefix"] .. "(out) " .. line)
    end
  end
  return core.filter(_6_, core.map(_7_, str.split(core.get(msg, "out"), "\n")))
end
M["eval-str"] = function(opts)
  local function _9_(repl)
    local function _10_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      opts["on-result"](core.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send((opts.code .. "\n"), _10_, {["batch?"] = true})
  end
  return with_repl_or_warn(_9_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function display_repl_status(status)
  return log.append({(M["comment-prefix"] .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
M.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return core.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _12_()
      return display_repl_status("started")
    end
    local function _13_(err)
      return display_repl_status(err)
    end
    local function _14_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with signal " .. signal)})
      else
      end
      return M.stop()
    end
    local function _17_(msg)
      return log.append(M["format-msg"](msg))
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
M.interrupt = function()
  local function _19_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_19_)
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  local function _20_()
    return M.start()
  end
  mapping.buf("RStart", cfg({"mapping", "start"}), _20_, {desc = "Start the R REPL"})
  local function _21_()
    return M.stop()
  end
  mapping.buf("RStop", cfg({"mapping", "stop"}), _21_, {desc = "Stop the R REPL"})
  local function _22_()
    return M.interrupt()
  end
  return mapping.buf("RInterrupt", cfg({"mapping", "interrupt"}), _22_, {desc = "Interrupt the R REPL"})
end
M["on-exit"] = function()
  return M.stop()
end
return M
