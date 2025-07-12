-- [nfnl] fnl/conjure/client/snd-s7/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local stdio = autoload("conjure.remote.stdio-rt")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.snd-s7.stdio")
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
M["buf-suffix"] = ".scm"
M["comment-prefix"] = "; "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
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
M["->list"] = function(s)
  if a.first(s) then
    return s
  else
    return {s}
  end
end
local function split_and_join(s)
  local function _7_(_241)
    return string.gsub(str.trimr(_241), "%s*%;[^\n]*$", "")
  end
  return str.join(a.map(_7_, text["split-lines"](s)))
end
M["eval-str"] = function(opts)
  log.dbg(("eval-str: opts >>" .. a["pr-str"](opts) .. "<<"))
  log.dbg(("eval-str: opts.code >>" .. a["pr-str"](opts.code) .. "<<"))
  local function _8_(repl)
    local function _9_(msgs)
      local msgs0 = M["->list"](msgs)
      if opts["on-result"] then
        opts["on-result"](str.join("\n", remove_blank_lines(a.last(msgs0))))
      else
      end
      return a["run!"](display_result, msgs0)
    end
    return repl.send((split_and_join(opts.code) .. "\n"), _9_, {["batch?"] = false})
  end
  return with_repl_or_warn(_8_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
M.interrupt = function()
  local function _11_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_11_)
end
local function display_repl_status(status)
  return log.append({(M["comment-prefix"] .. a["pr-str"](cfg({"command"})) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
M.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M.start = function()
  log.append({(M["comment-prefix"] .. "Starting snd-s7 client...")})
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _13_()
      return display_repl_status("started")
    end
    local function _14_(err)
      return display_repl_status(err)
    end
    local function _15_(code, signal)
      log.dbg("process exited with code ", a["pr-str"](code))
      log.dbg("process exited with signal ", a["pr-str"](signal))
      return M.stop()
    end
    local function _16_(msg)
      return display_result(msg)
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _13_, ["on-error"] = _14_, ["on-exit"] = _15_, ["on-stray-output"] = _16_}))
  end
end
M["on-load"] = function()
  if config["get-in"]({"client_on_load"}) then
    return M.start()
  else
    return nil
  end
end
M["on-exit"] = function()
  return M.stop()
end
M["on-filetype"] = function()
  local function _19_()
    return M.start()
  end
  mapping.buf("SndStart", cfg({"mapping", "start"}), _19_, {desc = "Start the REPL"})
  local function _20_()
    return M.stop()
  end
  mapping.buf("SndStop", cfg({"mapping", "stop"}), _20_, {desc = "Stop the REPL"})
  local function _21_()
    return M.interrupt()
  end
  return mapping.buf("SndInterrupt", cfg({"mapping", "interrupt"}), _21_, {desc = "Interrupt the current REPL"})
end
return M
