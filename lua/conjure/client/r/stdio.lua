-- [nfnl] fnl/conjure/client/r/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
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
local buf_suffix = ".r"
local comment_prefix = "# "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, _)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function unbatch(msgs)
  local function _5_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return {out = str.join("", core.map(_5_, msgs))}
end
local function format_msg(msg)
  local function _6_(_241)
    return not str["blank?"](_241)
  end
  local function _7_(line)
    if not cfg({"value_prefix_pattern"}) then
      return line
    elseif string.match(line, cfg({"value_prefix_pattern"})) then
      return string.gsub(line, cfg({"value_prefix_pattern"}), "")
    else
      return (comment_prefix .. "(out) " .. line)
    end
  end
  return core.filter(_6_, core.map(_7_, str.split(core.get(msg, "out"), "\n")))
end
local function eval_str(opts)
  local function _9_(repl)
    local function _10_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      opts["on-result"](core.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send((opts.code .. "\n"), _10_, {["batch?"] = true})
  end
  return with_repl_or_warn(_9_)
end
local function eval_file(opts)
  return eval_str(core.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return core.assoc(state(), "repl", nil)
  else
    return nil
  end
end
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _12_()
      return display_repl_status("started")
    end
    local function _13_(err)
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
      return log.append(format_msg(msg))
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
local function interrupt()
  local function _19_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_19_)
end
local function on_load()
  return start()
end
local function on_filetype()
  mapping.buf("RStart", cfg({"mapping", "start"}), start, {desc = "Start the R REPL"})
  mapping.buf("RStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the R REPL"})
  return mapping.buf("RInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the R REPL"})
end
local function on_exit()
  return stop()
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, unbatch = unbatch, ["format-msg"] = format_msg, ["eval-str"] = eval_str, ["eval-file"] = eval_file, stop = stop, start = start, interrupt = interrupt, ["on-load"] = on_load, ["on-filetype"] = on_filetype, ["on-exit"] = on_exit}
