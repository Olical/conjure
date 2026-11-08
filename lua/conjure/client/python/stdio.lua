-- [nfnl] fnl/conjure/client/python/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local b64 = autoload("conjure.remote.transport.base64")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.python.stdio")
config.merge({client = {python = {stdio = {command = "python3 -iq", prompt_pattern = ">>> $", delay_stderr_ms = 10, auto_set_file = true}}}})
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
  log.dbg("--------------------")
  log.dbg(("python.stdio.form-node?: node:type:" .. core["pr-str"](node:type())))
  log.dbg(("python.stdio.form-node?: node:parent:" .. core["pr-str"](node:parent())))
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
  local tree = core.get(result, 1)
  local root = tree:root()
  return ((1 == root:child_count()) and M["is-expression?"](root:child(0)))
end
local function source_file_path(opts)
  if (opts["file-path"] and ("" ~= opts["file-path"])) then
    return opts["file-path"]
  else
    return "<conjure>"
  end
end
local function decoded_file_path_str(opts)
  return ("base64.b64decode('" .. b64.encode(source_file_path(opts)) .. "').decode()")
end
local function set_file_prefix(opts)
  if cfg({"auto_set_file"}) then
    return ("__file__ = " .. decoded_file_path_str(opts) .. "; ")
  else
    return ""
  end
end
local function get_exec_str(opts)
  local _10_
  if cfg({"auto_set_file"}) then
    _10_ = "__file__"
  else
    _10_ = decoded_file_path_str(opts)
  end
  return (set_file_prefix(opts) .. "exec(compile(base64.b64decode('" .. b64.encode(opts.code) .. "'), " .. _10_ .. ", 'exec'))\n")
end
M["prep-code"] = function(opts)
  local s = opts.code
  local python_expr = M["str-is-python-expr?"](s)
  if python_expr then
    return (set_file_prefix(opts) .. s .. "\n")
  else
    return get_exec_str(opts)
  end
end
local function is_dots_3f(s)
  return (string.sub(s, 1, 3) == "...")
end
M["format-msg"] = function(msg)
  log.dbg(("python.stdio.format-msg: msg:'" .. core.str(msg) .. "'"))
  local function _13_(_241)
    return not is_dots_3f(_241)
  end
  local function _14_(_241)
    return ("" ~= _241)
  end
  return core.filter(_13_, core.filter(_14_, text["split-lines"](msg)))
end
local function get_console_output_msgs(msgs)
  local function _15_(_241)
    return (M["comment-prefix"] .. "(out) " .. _241)
  end
  return core.map(_15_, core.butlast(msgs))
end
local function get_expression_result(msgs)
  local result = core.last(msgs)
  if (core["nil?"](result) or is_dots_3f(result)) then
    return nil
  else
    return result
  end
end
M.unbatch = function(msgs)
  log.dbg(("python.stdio.unbatch: msgs:'" .. core.str(msgs) .. "'"))
  local function _17_(_241)
    return (core.get(_241, "out") or core.get(_241, "err"))
  end
  return str.join("", core.map(_17_, msgs))
end
local function log_repl_output(msgs)
  log.dbg(("python.stdio.log-repl-output: msgs:'" .. core.str(msgs) .. "'"))
  local msgs0 = M["format-msg"](M.unbatch(msgs))
  local console_output_msgs = get_console_output_msgs(msgs0)
  local cmd_result = get_expression_result(msgs0)
  if not core["empty?"](console_output_msgs) then
    log.dbg(("python.stdio.log-repl-output: console-output-msgs:'" .. core.str(console_output_msgs) .. "'"))
    log.append(console_output_msgs)
  else
  end
  if cmd_result then
    log.dbg(("python.stdio.log-repl-output: cmd-result:'" .. core.str(cmd_result) .. "'"))
    return log.append({cmd_result})
  else
    return nil
  end
end
M["eval-str"] = function(opts)
  log.dbg(("python.stdio.eval-str opts:'" .. core.str(opts) .. "'"))
  local function _20_(repl)
    local function _21_(msgs)
      log_repl_output(msgs)
      if opts["on-result"] then
        local msgs0 = M["format-msg"](M.unbatch(msgs))
        local cmd_result = get_expression_result(msgs0)
        return opts["on-result"](cmd_result)
      else
        return nil
      end
    end
    return repl.send(M["prep-code"](opts), _21_, {["batch?"] = true})
  end
  return with_repl_or_warn(_20_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](core.assoc(opts, "code", core.slurp(opts["file-path"])))
end
M["get-help"] = function(code)
  return str.join("", {"help(", str.trim(code), ")"})
end
M["doc-str"] = function(opts)
  if M["str-is-python-expr?"](opts.code) then
    return M["eval-str"](core.assoc(opts, "code", M["get-help"](opts.code)))
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
    return core.assoc(state(), "repl", nil)
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
    if not ts["add-language"]("python") then
      return log.append({(M["comment-prefix"] .. "(error) The python client requires a python treesitter parser in order to function."), (M["comment-prefix"] .. "(error) See https://github.com/nvim-treesitter/nvim-treesitter"), (M["comment-prefix"] .. "(error) for installation instructions.")})
    else
      local function _25_()
        display_repl_status("started")
        local function _26_(repl)
          local function _27_(msgs)
            return nil
          end
          repl.send("import base64\n", _27_, nil)
          local function _28_(msgs)
            return nil
          end
          return repl.send(M["prep-code"]({code = M["initialise-repl-code"]}), _28_, nil)
        end
        return with_repl_or_warn(_26_)
      end
      local function _29_(err)
        return display_repl_status(err)
      end
      local function _30_(code, signal)
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
      local function _33_(msg)
        return log.dbg(M["format-msg"](M.unbatch({msg})), {["join-first?"] = true})
      end
      return core.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), ["await-initial-prompt?"] = true, cmd = cfg({"command"}), ["delay-stderr-ms"] = cfg({"delay_stderr_ms"}), ["on-success"] = _25_, ["on-error"] = _29_, ["on-exit"] = _30_, ["on-stray-output"] = _33_}))
    end
  end
end
M["on-exit"] = function()
  return M.stop()
end
M.interrupt = function()
  local function _36_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_36_)
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  local function _37_()
    return M.start()
  end
  mapping.buf("PythonStart", cfg({"mapping", "start"}), _37_, {desc = "Start the Python REPL"})
  local function _38_()
    return M.stop()
  end
  mapping.buf("PythonStop", cfg({"mapping", "stop"}), _38_, {desc = "Stop the Python REPL"})
  local function _39_()
    return M.interrupt()
  end
  return mapping.buf("PythonInterrupt", cfg({"mapping", "interrupt"}), _39_, {desc = "Interrupt the current evaluation"})
end
return M
