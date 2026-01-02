-- [nfnl] fnl/conjure/client/ruby/stdio.fnl
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
local M = define("conjure.client.ruby.stdio")
M["buf-suffix"] = ".rb"
M["comment-prefix"] = "# "
config.merge({client = {ruby = {stdio = {command = "irb --no-pager --nocolorize --noautocomplete --noecho-on-assignment --simple-prompt", prompt_pattern = ">> ", value_prefix_pattern = "=> "}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {ruby = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "ruby", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["form-node?"] = function(node)
  log.dbg("--------------------")
  log.dbg(("ruby.stdio.form-node?: node:type = " .. core.str(node:type())))
  log.dbg(("ruby.stdio.form-node?: node:parent = " .. core.str(node:parent())))
  local parent = node:parent()
  if (("binary" == node:type()) and not ("binary" == parent:type())) then
    return true
  elseif ("binary" == node:type()) then
    return true
  elseif (("left" == node:type()) and ("assignment" == parent:type())) then
    return true
  elseif (("call" == node:type()) and not ("assignment" == parent:type())) then
    return true
  elseif ("arguments" == node:type()) then
    return true
  elseif ("class" == node:type()) then
    return true
  elseif ("method" == node:type()) then
    return true
  elseif ("array" == node:type()) then
    return true
  elseif ("hash" == node:type()) then
    return true
  elseif ("symbol" == node:type()) then
    return true
  elseif ("integer" == node:type()) then
    return true
  elseif ("float" == node:type()) then
    return true
  elseif ("string" == node:type()) then
    return true
  elseif ("assignment" == node:type()) then
    return true
  elseif ("identifier" == node:type()) then
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
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
local function prep_code(s)
  return (s .. "\n")
end
local function display_result(msg)
  local function _6_(_241)
    return (M["comment-prefix"] .. _241)
  end
  return log.append(core.map(_6_, msg))
end
M.unbatch = function(msgs)
  log.dbg(("ruby.stdio.unbatch: msgs='" .. core.str(msgs) .. "'"))
  local function _7_(_241)
    return string.gsub(_241, "\n$", "")
  end
  local function _8_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return core.map(_7_, core.map(_8_, msgs))
end
local function has_error_3f(line)
  log.dbg(("ruby.stdio.has_error? line='" .. core.str(line) .. "'"))
  if core["nil?"](line) then
    return false
  else
    return not core["empty?"](string.match(line, "Error"))
  end
end
local function extract_error_msg(line)
  log.dbg(("ruby.stdio.extract_error_msg: line='" .. core.str(line) .. "'"))
  return core.first(str.split(line, "\n"))
end
local function format_line(line)
  local value_prefix_pat = cfg({"value_prefix_pattern"})
  local gsub_value_prefix_pat = ("^.*" .. "=> ")
  log.dbg(("ruby.stdio.format-line: line='" .. core.str(line) .. "'"))
  log.dbg(("format-line: value_prefix_pat='" .. core.str(value_prefix_pat) .. "'"))
  log.dbg(("format-line: gsub_value_prefix_pat='" .. core.str(gsub_value_prefix_pat) .. "'"))
  if string.match(line, value_prefix_pat) then
    log.dbg(("format-line: line has '" .. value_prefix_pat .. "'"))
    return string.gsub(line, gsub_value_prefix_pat, "")
  elseif has_error_3f(line) then
    return ("(error) " .. extract_error_msg(line))
  else
    return (M["comment-prefix"] .. "(out) " .. line)
  end
end
M["format-msg"] = function(msgs)
  log.dbg(("ruby.stdio.format-msg: msgs='" .. core.str(msgs) .. "'"))
  local function _11_(_241)
    return not str["blank?"](_241)
  end
  local function _12_(_241)
    return string.gsub(_241, "\n$", "")
  end
  return core.map(format_line, core.filter(_11_, core.filter(_12_, msgs)))
end
M["eval-str"] = function(opts)
  log.dbg(("ruby.stdio.eval-str: opts='" .. core.str(opts) .. "'"))
  local function _13_(repl)
    log.dbg(("ruby.stdio.eval-str: sending '" .. core.str(opts.code) .. "'"))
    local function _14_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      log.dbg(("cb from repl.send (ruby.stdio.eval-str): msgs='" .. core.str(msgs0) .. "'"))
      opts["on-result"](core.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send(prep_code(opts.code), _14_, {["batch?"] = true})
  end
  return with_repl_or_warn(_13_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
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
  log.dbg(("ruby.stdio.start: prompt_pattern='" .. cfg({"prompt_pattern"}) .. "', cmd='" .. cfg({"command"}) .. "'"))
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _16_()
      display_repl_status("started")
      local function _17_(repl)
        local function _18_(msgs)
          return display_result(M["format-msg"](M.unbatch(msgs)))
        end
        return repl.send(prep_code(":help"), _18_, {["batch?"] = true})
      end
      return with_repl_or_warn(_17_)
    end
    local function _19_(err)
      return display_repl_status(err)
    end
    local function _20_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with code " .. core.str(code))})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with signal " .. core.str(signal))})
      else
      end
      return M.stop()
    end
    local function _23_(msg)
      return log.append(M["format-msg"](msg))
    end
    return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _16_, ["on-error"] = _19_, ["on-exit"] = _20_, ["on-stray-output"] = _23_}))
  end
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _25_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_25_)
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  local function _26_()
    return M.start()
  end
  mapping.buf("RubyStart", cfg({"mapping", "start"}), _26_, {desc = "Start the REPL"})
  local function _27_()
    return M.stop()
  end
  mapping.buf("RubyStop", cfg({"mapping", "stop"}), _27_, {desc = "Stop the REPL"})
  local function _28_()
    return M.interrupt()
  end
  return mapping.buf("RubyInterrupt", cfg({"mapping", "interrupt"}), _28_, {desc = "Interrupt the REPL"})
end
return M
