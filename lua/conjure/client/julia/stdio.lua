-- [nfnl] fnl/conjure/client/julia/stdio.fnl
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
local M = define("conjure.client.julia.stdio")
config.merge({client = {julia = {stdio = {command = "julia --banner=no --color=no -i", prompt_pattern = ""}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {julia = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "julia", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".jl"
M["comment-prefix"] = "# "
M["form-node?"] = function(node)
  local parent = node:parent()
  return (not (("call_expression" == parent:type()) and ("field_expression" == node:type())) and not ("assignment" == parent:type()) and ("argument_list" ~= node:type()))
end
local function with_repl_or_warn(f, _opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running"), (M["comment-prefix"] .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function prep_code(s)
  return (s .. "\nif(isnothing(ans)) display(nothing) end\n")
end
M.unbatch = function(msgs)
  local function _5_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return str.join("", core.map(_5_, msgs))
end
M["format-msg"] = function(msg)
  local function _6_(_241)
    return ("" ~= _241)
  end
  return core.filter(_6_, str.split(string.gsub(msg, "(.?[%w\n])(nothing)", "%1"), "\n"))
end
M["get-form-modifier"] = function(node)
  if (";" == ts["node->str"](node:next_sibling())) then
    return {modifier = "raw", ["node-table"] = {content = (ts["node->str"](node) .. ";"), range = core["update-in"](ts.range(node), {"end", 2}, core.inc)}}
  else
    return nil
  end
end
M["eval-str"] = function(opts)
  local function _8_(repl)
    local function _9_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      log.append(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(string.gsub(opts.code, ";$", "; nothing;")), _9_, {["batch?"] = true})
  end
  return with_repl_or_warn(_8_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["doc-str"] = function(opts)
  local function _11_(_241)
    return ("Main.eval(REPL.helpmode(\"" .. _241 .. "\"))")
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
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _14_()
      display_repl_status("started")
      local function _15_(repl)
        local function _16_(msgs)
          return log.append(M["format-msg"](M.unbatch(msgs)))
        end
        return repl.send(prep_code("using REPL"), _16_, {["batch?"] = true})
      end
      return with_repl_or_warn(_15_)
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
      return log.append(M["format-msg"](M.unbatch({msg})), {["join-first?"] = true})
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
M["on-filetype"] = function()
  local function _24_()
    return M.start()
  end
  mapping.buf("JuliaStart", cfg({"mapping", "start"}), _24_, {desc = "Start the REPL"})
  local function _25_()
    return M.stop()
  end
  mapping.buf("JuliaStop", cfg({"mapping", "stop"}), _25_, {desc = "Stop the REPL"})
  local function _26_()
    return M.interrupt()
  end
  return mapping.buf("JuliaInterrupt", cfg({"mapping", "interrupt"}), _26_, {desc = "Interrupt the evaluation"})
end
return M
