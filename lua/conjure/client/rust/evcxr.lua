-- [nfnl] fnl/conjure/client/rust/evcxr.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local stdio = autoload("conjure.remote.stdio")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.client.rust.evcxr")
M["buf-suffix"] = ".rs"
M["comment-prefix"] = "// "
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
M["form-node?"] = function(node)
  log.dbg("form-node?: node:type =", node:type())
  log.dbg("form-node?: node:parent =", node:parent())
  local parent = node:parent()
  if ("struct_item" == node:type()) then
    return true
  elseif ("let_declaration" == node:type()) then
    return true
  elseif ("index_expression" == node:type()) then
    return true
  elseif ("expression_statement" == node:type()) then
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
    return not ("()" == _241)
  end
  local function _9_(_241)
    return not ("" == _241)
  end
  return core.filter(_8_, core.filter(_9_, str.split(msg, "\n")))
end
local function unbatch(msgs)
  local function _10_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return str.join("", core.map(_10_, msgs))
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
    local function _12_()
      display_repl_status("started")
      local function _13_(repl)
        local function _14_(msgs)
          return display_result(format_msg(unbatch(msgs)))
        end
        return repl.send(prep_code(":help"), _14_, {["batch?"] = true})
      end
      return with_repl_or_warn(_13_)
    end
    local function _15_(err)
      log.append({"error"})
      return display_repl_status(err)
    end
    local function _16_(code, signal)
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
    local function _19_(msg)
      return display_result(format_msg(unbatch({msg})), {["join-first?"] = true})
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _15_, ["on-exit"] = _16_, ["on-stray-output"] = _19_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _21_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_21_)
end
M["eval-str"] = function(opts)
  local function _22_(repl)
    local function _23_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _23_, {["batch?"] = true})
  end
  return with_repl_or_warn(_22_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["on-filetype"] = function()
  local function _25_()
    return M.start()
  end
  mapping.buf("RustStart", cfg({"mapping", "start"}), _25_, {desc = "Start the Rust REPL"})
  local function _26_()
    return M.stop()
  end
  mapping.buf("RustStop", cfg({"mapping", "stop"}), _26_, {desc = "Stop the Rust REPL"})
  local function _27_()
    return M.interrupt()
  end
  return mapping.buf("RustInterrupt", cfg({"mapping", "interrupt"}), _27_, {desc = "Interrupt the current evaluation"})
end
return M
