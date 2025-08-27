-- [nfnl] fnl/conjure/client/racket/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local core = autoload("conjure.nfnl.core")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local stdio = autoload("conjure.remote.stdio")
local str = autoload("conjure.nfnl.string")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.racket.stdio")
config.merge({client = {racket = {stdio = {command = "racket", prompt_pattern = "\n?[\"%w%-./_]*> ", auto_enter = true}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {racket = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "racket", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".rkt"
M["comment-prefix"] = "; "
M["context-pattern"] = "%(%s*module%s+(.-)[%s){]"
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, _opts)
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
local function display_result(msg)
  local function _5_(_241)
    return not ("" == _241)
  end
  return log.append(core.filter(_5_, format_message(msg)))
end
local function prep_code(s)
  local lang_line_pat = "#lang [^%s]+"
  local code
  if s:match(lang_line_pat) then
    log.append({(M["comment-prefix"] .. "Dropping #lang, only supported in file evaluation.")})
    code = s:gsub(lang_line_pat, "")
  else
    code = s
  end
  return (code .. "\n(flush-output)")
end
M["eval-str"] = function(opts)
  local function _7_(repl)
    local function _8_(msgs)
      if ((1 == core.count(msgs)) and ("" == core["get-in"](msgs, {1, "out"}))) then
        core["assoc-in"](msgs, {1, "out"}, (M["comment-prefix"] .. "Empty result."))
      else
      end
      opts["on-result"](str.join("\n", core.mapcat(format_message, msgs)))
      return core["run!"](display_result, msgs)
    end
    return repl.send(prep_code(opts.code), _8_, {["batch?"] = true})
  end
  return with_repl_or_warn(_7_)
end
M.interrupt = function()
  local function _10_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_10_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", (",require-reloadable " .. opts["file-path"])))
end
M["doc-str"] = function(opts)
  local function _11_(_241)
    return (",doc " .. _241)
  end
  return M["eval-str"](core.update(opts, "code", _11_))
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. core["pr-str"](core["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
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
M.enter = function()
  local repl = state("repl")
  local path = vim.fn.expand("%:p")
  if (repl and not log["log-buf?"](path) and cfg({"auto_enter"})) then
    local function _14_()
    end
    return repl.send(prep_code((",enter " .. path)), _14_)
  else
    return nil
  end
end
M.start = function()
  if state("repl") then
    return log.append({"; Can't start, REPL is already running.", ("; Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _16_()
      display_repl_status("started")
      return M.enter()
    end
    local function _17_(err)
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
      return display_result(msg)
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _16_, ["on-error"] = _17_, ["on-exit"] = _18_, ["on-stray-output"] = _21_}))
  end
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  local function _23_()
    return M.start()
  end
  mapping.buf("RktStart", cfg({"mapping", "start"}), _23_, {desc = "Start the REPL"})
  local function _24_()
    return M.stop()
  end
  mapping.buf("RktStop", cfg({"mapping", "stop"}), _24_, {desc = "Stop the REPL"})
  local function _25_()
    return M.interrupt()
  end
  return mapping.buf("RktInterrupt", cfg({"mapping", "interrupt"}), _25_, {desc = "Interrupt the current evaluation"})
end
M["on-exit"] = function()
  return M.stop()
end
return M
