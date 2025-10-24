-- [nfnl] fnl/conjure/client/php/psysh.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local stdio = autoload("conjure.remote.stdio")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local M = define("conjure.client.php.psysh")
config.merge({client = {php = {psysh = {command = "psysh -ir --no-color", prompt_pattern = "> ", ["delay-stderr-ms"] = 10}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {php = {psysh = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "php", "psysh"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".php"
M["comment-prefix"] = "// "
M["form-node?"] = function(node)
  log.dbg("form-node?: node:type =", node:type())
  log.dbg("form-node?: node:parent =", node:parent())
  local parent = node:parent()
  if ("expression_statement" == node:type()) then
    return true
  elseif ("import_statement" == node:type()) then
    return true
  elseif ("import_from_statement" == node:type()) then
    return true
  elseif ("with_statement" == node:type()) then
    return true
  elseif ("decorated_definition" == node:type()) then
    return true
  elseif ("for_statement" == node:type()) then
    return true
  elseif ("call" == node:type()) then
    return true
  elseif (("class_definition" == node:type()) and not ("decorated_definition" == parent:type())) then
    return true
  elseif (("function_definition" == node:type()) and not ("decorated_definition" == parent:type())) then
    return true
  else
    return false
  end
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running"), (M["comment-prefix"] .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. core["pr-str"](core["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return log.append({status})
  end
end
local function display_result(msg)
  local function _7_(_241)
    return (M["comment-prefix"] .. _241)
  end
  return log.append(core.map(_7_, msg))
end
local function format_msg(msg)
  local function _8_(_241)
    return string.sub(_241, 3)
  end
  local function _9_(_241)
    return text["starts-with"](_241, "= ")
  end
  local function _10_(_241)
    return not ("" == _241)
  end
  local function _11_(_241)
    return str.trim(_241)
  end
  return core.map(_8_, core.filter(_9_, core.filter(_10_, core.map(_11_, str.split(msg, "\n")))))
end
local function unbatch(msgs)
  local function _12_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return str.join("", core.map(_12_, msgs))
end
local function prep_code(s)
  return (s .. "\n")
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
    local function _14_()
      display_repl_status("started")
      local function _15_(repl)
        local function _16_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code("help"), _16_, {["batch?"] = true})
      end
      return with_repl_or_warn(_15_)
    end
    local function _17_(err)
      log.append({"error"})
      return display_repl_status(err)
    end
    local function _18_(code, signal)
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
    local function _21_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _14_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _23_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_23_)
end
M["eval-str"] = function(opts)
  local function _24_(repl)
    local function _25_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _25_, {["batch?"] = true})
  end
  return with_repl_or_warn(_24_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["on-filetype"] = function()
  local function _27_()
    return M.start()
  end
  mapping.buf("phpStart", cfg({"mapping", "start"}), _27_, {desc = "Start the PHP REPL"})
  local function _28_()
    return M.stop()
  end
  mapping.buf("phpStop", cfg({"mapping", "stop"}), _28_, {desc = "Stop the PHP REPL"})
  local function _29_()
    return M.interrupt()
  end
  return mapping.buf("phpInterrupt", cfg({"mapping", "interrupt"}), _29_, {desc = "Interrupt the current evaluation"})
end
return M
