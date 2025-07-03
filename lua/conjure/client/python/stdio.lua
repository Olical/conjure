-- [nfnl] fnl/conjure/client/python/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local b64 = autoload("conjure.remote.transport.base64")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.python.stdio")
config.merge({client = {python = {stdio = {command = "python3 -iq", ["prompt-pattern"] = ">>> ", ["delay-stderr-ms"] = 10}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {python = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "python", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".py"
M["comment-prefix"] = "# "
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
M["is-assignment?"] = function(node)
  local and_6_ = (node:child_count() == 1)
  if and_6_ then
    local child = node:child(0)
    and_6_ = (child:type() == "assignment")
  end
  return and_6_
end
M["is-expression?"] = function(node)
  return (("expression_statement" == node:type()) and not M["is-assignment?"](node))
end
M["str-is-python-expr?"] = function(s)
  local parser = vim.treesitter.get_string_parser(s, "python")
  local result = parser:parse()
  local tree = a.get(result, 1)
  local root = tree:root()
  return ((1 == root:child_count()) and M["is-expression?"](root:child(0)))
end
local function get_exec_str(s)
  return ("import base64\nexec(base64.b64decode('" .. b64.encode(s) .. "'))\n")
end
local function prep_code(s)
  local python_expr = M["str-is-python-expr?"](s)
  if python_expr then
    return (s .. "\n")
  else
    return get_exec_str(s)
  end
end
local function is_dots_3f(s)
  return (string.sub(s, 1, 3) == "...")
end
M["format-msg"] = function(msg)
  local function _9_(_241)
    return not is_dots_3f(_241)
  end
  local function _10_(_241)
    return ("" ~= _241)
  end
  return a.filter(_9_, a.filter(_10_, text["split-lines"](msg)))
end
local function get_console_output_msgs(msgs)
  local function _11_(_241)
    return (M["comment-prefix"] .. "(out) " .. _241)
  end
  return a.map(_11_, a.butlast(msgs))
end
local function get_expression_result(msgs)
  local result = a.last(msgs)
  if (a["nil?"](result) or is_dots_3f(result)) then
    return nil
  else
    return result
  end
end
M.unbatch = function(msgs)
  local function _13_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_13_, msgs))
end
local function log_repl_output(msgs)
  local msgs0 = M["format-msg"](M.unbatch(msgs))
  local console_output_msgs = get_console_output_msgs(msgs0)
  local cmd_result = get_expression_result(msgs0)
  if not a["empty?"](console_output_msgs) then
    log.append(console_output_msgs)
  else
  end
  if cmd_result then
    return log.append({cmd_result})
  else
    return nil
  end
end
M["eval-str"] = function(opts)
  local function _16_(repl)
    local function _17_(msgs)
      log_repl_output(msgs)
      if opts["on-result"] then
        local msgs0 = M["format-msg"](M.unbatch(msgs))
        local cmd_result = get_expression_result(msgs0)
        return opts["on-result"](cmd_result)
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _17_, {["batch?"] = true})
  end
  return with_repl_or_warn(_16_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
M["get-help"] = function(code)
  return str.join("", {"help(", str.trim(code), ")"})
end
M["doc-str"] = function(opts)
  if M["str-is-python-expr?"](opts.code) then
    return M["eval-str"](a.assoc(opts, "code", M["get-help"](opts.code)))
  else
    return nil
  end
end
local function display_repl_status(status)
  return log.append({(M["comment-prefix"] .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
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
M["initialise-repl-code"] = str.join("\n", {"import sys", "def conjure_format_output(val):", "    print(repr(val))", "sys.displayhook = conjure_format_output\n", "__name__ = '__repl__'"})
M.start = function()
  log.append({(M["comment-prefix"] .. "Starting Python client...")})
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _21_()
      return ts["add-language"]("python")
    end
    if not pcall(_21_) then
      return log.append({(M["comment-prefix"] .. "(error) The python client requires a python treesitter parser in order to function."), (M["comment-prefix"] .. "(error) See https://github.com/nvim-treesitter/nvim-treesitter"), (M["comment-prefix"] .. "(error) for installation instructions.")})
    else
      local function _22_()
        local function _23_(repl)
          local function _24_(msgs)
            return nil
          end
          return repl.send(prep_code(M["initialise-repl-code"]), _24_, nil)
        end
        return display_repl_status("started", with_repl_or_warn(_23_))
      end
      local function _25_(err)
        return display_repl_status(err)
      end
      local function _26_(code, signal)
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
      local function _29_(msg)
        return log.dbg(M["format-msg"](M.unbatch({msg})), {["join-first?"] = true})
      end
      return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt-pattern"}), cmd = cfg({"command"}), ["delay-stderr-ms"] = cfg({"delay-stderr-ms"}), ["on-success"] = _22_, ["on-error"] = _25_, ["on-exit"] = _26_, ["on-stray-output"] = _29_}))
    end
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
M["on-load"] = function()
  if config["get-in"]({"client_on_load"}) then
    return M.start()
  else
    return nil
  end
end
M["on-filetype"] = function()
  mapping.buf("PythonStart", cfg({"mapping", "start"}), M.start, {desc = "Start the Python REPL"})
  mapping.buf("PythonStop", cfg({"mapping", "stop"}), M.stop, {desc = "Stop the Python REPL"})
  return mapping.buf("PythonInterrupt", cfg({"mapping", "interrupt"}), M.interrupt, {desc = "Interrupt the current evaluation"})
end
return M
