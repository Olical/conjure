-- [nfnl] fnl/conjure/client/javascript/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local import_replacer = autoload("conjure.client.javascript.import-replacer")
local transformers = autoload("conjure.client.javascript.transformers")
local M = define("conjure.client.javascript.stdio")
config.merge({client = {javascript = {stdio = {args = "NODE_OPTIONS='--experimental-repl-await'", ["prompt-pattern"] = "> ", show_stray_out = false}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {javascript = {stdio = {mapping = {start = "cs", stop = "cS", restart = "cr", interrupt = "ei", stray = "ts"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "javascript", "stdio"})
M["buf-suffix"] = ".js"
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["comment-prefix"] = "// "
M["form-node?"] = function(node)
  return (("function_declaration" == node:type()) or ("export_statement" == node:type()) or ("try_statement" == node:type()) or ("expression_statement" == node:type()) or ("import_statement" == node:type()) or ("class_declaration" == node:type()) or ("type_alias_declaration" == node:type()) or ("enum_declaration" == node:type()) or ("lexical_declaration" == node:type()) or ("for_statement" == node:type()) or ("for_in_statement" == node:type()) or ("interface_declaration" == node:type()))
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running"), (M["comment-prefix"] .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_result(msg)
  return log.append(msg)
end
local function tap_3e(s)
  log.append({"TAP>>", a["pr-str"](s)})
  return s
end
local function prep_code_expr(e)
  return import_replacer["replace-imports"](transformers.transform(e))
end
local function prep_code_file(f)
  return str.join("\n", a.map(prep_code_expr, str.split(f, "\n")))
end
local function prep_code(s)
  return (prep_code_expr(s) .. "\n")
end
local function replace_dots(s, with)
  local s0, _count = string.gsub(s, "%.%.%.%s?", with)
  return s0
end
M["format-msg"] = function(msg)
  local function _5_(_241)
    return replace_dots(_241, "")
  end
  local function _6_(_241)
    return ("" ~= _241)
  end
  return a.map(_5_, a.filter(_6_, str.split(msg, "\n")))
end
local function sanitize_msg(msg, field)
  local function _7_(_241)
    return ("(" .. field .. ") " .. _241 .. "\n")
  end
  local function _8_(...)
    return not str["blank?"](...)
  end
  local function _9_(_241)
    return replace_dots(_241, "")
  end
  return str.join("", a.map(_7_, a.filter(_8_, a.map(_9_, str.split(a.get(msg, field), "\n")))))
end
local function prepare_out(msg)
  if a.get(msg, "out") then
    return sanitize_msg(msg, "out")
  elseif a.get(msg, "err") then
    return sanitize_msg(msg, "err")
  else
    return nil
  end
end
M.unbatch = function(msgs)
  return str.join("", a.map(prepare_out, msgs))
end
local function stray_out()
  return config.merge({client = {javascript = {stdio = {show_stray_out = not cfg({"show_stray_out"})}}}}, {["overwrite?"] = true})
end
local function restart()
  M.stop()
  return M.start()
end
M["eval-str"] = function(opts)
  local function _11_(repl)
    local function _12_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        return opts["on-result"](str.join(" ", msgs0))
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _12_, {["batch?"] = true})
  end
  return with_repl_or_warn(_11_)
end
M["eval-file"] = function(opts)
  local function _14_(repl)
    local c = prep_code_file(a.slurp(opts["file-path"]))
    local tmp_name = (opts["file-path"] .. "_tmp")
    local _tmp = a.spit(tmp_name, c)
    log.dbg({"EVAL TEMP FILE: ", tmp_name})
    local function _15_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      display_result(msgs0)
      if opts["on-result"] then
        opts["on-result"](str.join(" ", msgs0))
      else
      end
      return vim.uv.fs_unlink(tmp_name, nil)
    end
    return repl.send((".load " .. tmp_name .. "\n"), _15_)
  end
  return with_repl_or_warn(_14_)
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(M["comment-prefix"] .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
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
M["initialise-repl-code"] = ""
local function repl_command_for_filetype()
  if ("javascript" == vim.bo.filetype) then
    return "node -i"
  elseif ("typescript" == vim.bo.filetype) then
    return "ts-node -i"
  else
    return nil
  end
end
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _20_()
      display_repl_status("started")
      local function _21_(repl)
        local function _22_(msgs)
          return display_result(M["format-msg"](M.unbatch(msgs)))
        end
        return repl.send(prep_code(M["initialise-repl-code"]), _22_, {batch = true})
      end
      return with_repl_or_warn(_21_)
    end
    local function _23_(err)
      return display_repl_status(err)
    end
    local function _24_(code, signal)
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
    local function _27_(msg)
      if cfg({"show_stray_out"}) then
        return display_result(M["format-msg"](M.unbatch({msg})))
      else
        return nil
      end
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt-pattern"}), cmd = repl_command_for_filetype(), ["delay-stderr-ms"] = cfg({"delay-stderr-ms"}), ["on-success"] = _20_, ["on-error"] = _23_, ["on-exit"] = _24_, ["on-stray-output"] = _27_}))
  end
end
local function warning_msg()
  local function _30_(_241)
    return log.append({_241})
  end
  return a.map(_30_, {"// WARNING! Node.js REPL limitations require transformations:", "// 1. ES6 'import' statements are converted to 'require(...)' calls.", "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."})
end
M["on-load"] = function()
  if config["get-in"]({"client_on_load"}) then
    M.start()
    return warning_msg()
  else
    return log.append({"Not starting repl"})
  end
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _32_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_32_)
end
M["on-filetype"] = function()
  mapping.buf("JavascriptStart", cfg({"mapping", "start"}), M.start, {desc = "Start the Javascript REPL"})
  mapping.buf("JavascriptStop", cfg({"mapping", "stop"}), M.stop, {desc = "Stop the Javascript REPL"})
  mapping.buf("JavascriptRestart", cfg({"mapping", "restart"}), restart, {desc = "Restart the Javascript REPL"})
  mapping.buf("JavascriptInterrupt", cfg({"mapping", "interrupt"}), M.interrupt, {desc = "Interrupt the current evaluation"})
  return mapping.buf("JavascriptStray", cfg({"mapping", "stray"}), stray_out, {desc = "Toggle stray out"})
end
return M
