-- [nfnl] fnl/conjure/client/php/psysh.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local stdio = autoload("conjure.remote.stdio")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
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
local buf_suffix = ".php"
local comment_prefix = "// "
local function form_node_3f(node)
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
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. core["pr-str"](core["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return log.append({status})
  end
end
local function display_result(msg)
  local function _7_(_241)
    return (comment_prefix .. _241)
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
        log.append({(comment_prefix .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(comment_prefix .. "process exited with signal " .. signal)})
      else
      end
      return stop()
    end
    local function _21_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _14_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
local function on_load()
  return start()
end
local function on_exit()
  return stop()
end
local function interrupt()
  local function _23_(repl)
    log.append({(comment_prefix .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_23_)
end
local function eval_str(opts)
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
local function eval_file(opts)
  return eval_str(core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
local function on_filetype()
  mapping.buf("phpStart", cfg({"mapping", "start"}), start, {desc = "Start the PHP REPL"})
  mapping.buf("phpStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the PHP REPL"})
  return mapping.buf("phpInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["eval-str"] = eval_str, ["eval-file"] = eval_file, ["form-node?"] = form_node_3f, interrupt = interrupt, ["on-exit"] = on_exit, ["on-filetype"] = on_filetype, ["on-load"] = on_load, start = start, stop = stop}
