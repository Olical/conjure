-- [nfnl] Compiled from fnl/conjure/client/snd-s7/stdio.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local str = autoload("conjure.aniseed.string")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local stdio = autoload("conjure.remote.stdio-rt")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local ts = autoload("conjure.tree-sitter")
config.merge({client = {["snd-s7"] = {stdio = {command = "snd", prompt_pattern = "> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {["snd-s7"] = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "snd-s7", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
local buf_suffix = ".scm"
local comment_prefix = "; "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
local function remove_blank_lines(msg)
  local function _5_(_241)
    return not ("" == _241)
  end
  return a.filter(_5_, format_message(msg))
end
local function display_result(msg)
  return log.append(remove_blank_lines(msg))
end
local function __3elist(s)
  if a.first(s) then
    return s
  else
    return {s}
  end
end
local function eval_str(opts)
  local function _7_(repl)
    local function _8_(msgs)
      local msgs0 = __3elist(msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", remove_blank_lines(a.last(msgs0))))
      else
      end
      return a["run!"](display_result, msgs0)
    end
    return repl.send((opts.code .. "\n"), _8_, {["batch?"] = false})
  end
  return with_repl_or_warn(_7_)
end
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function interrupt()
  local function _10_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"](vim.loop.constants.SIGINT)
  end
  return with_repl_or_warn(_10_)
end
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
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
  log.append({(comment_prefix .. "Starting snd-s7 client...")})
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
      return log.append(__fnl_global__format_2dmsg(msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
local function on_load()
  if config["get-in"]({"client_on_load"}) then
    return start()
  else
    return nil
  end
end
local function on_exit()
  return stop()
end
local function on_filetype()
  mapping.buf("SndStart", cfg({"mapping", "start"}), start, {desc = "Start the REPL"})
  mapping.buf("SndStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the REPL"})
  return mapping.buf("SdnInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the REPL"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["->list"] = __3elist, ["eval-str"] = eval_str, ["eval-file"] = eval_file, interrupt = interrupt, stop = stop, start = start, ["on-load"] = on_load, ["on-exit"] = on_exit, ["on-filetype"] = on_filetype}
