local _2afile_2a = "fnl/conjure/client/python/stdio.fnl"
local _2amodule_name_2a = "conjure.client.python.stdio"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, b64, client, config, extract, log, mapping, nvim, stdio, str, text, ts, _ = autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.base64"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["b64"] = b64
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["_"] = _
config.merge({client = {python = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}, command = "python3 -iq", ["prompt-pattern"] = ">>> ", ["delay-stderr-ms"] = 10}}}})
local cfg = config["get-in-fn"]({"client", "python", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".py"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "# "
_2amodule_2a["comment-prefix"] = comment_prefix
local function form_node_3f(node)
  return (("expression_statement" == node:type()) or ("import_statement" == node:type()) or ("import_from_statement" == node:type()) or ("with_statement" == node:type()) or ("function_definition" == node:type()) or ("for_statement" == node:type()) or ("call" == node:type()))
end
_2amodule_2a["form-node?"] = form_node_3f
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function is_assignment_3f(node)
  local function _3_()
    local child = node:child(0)
    return (child:type() == "assignment")
  end
  return ((node:child_count() == 1) and _3_())
end
_2amodule_2a["is-assignment?"] = is_assignment_3f
local function is_expression_3f(node)
  return (("expression_statement" == node:type()) and not is_assignment_3f(node))
end
_2amodule_2a["is-expression?"] = is_expression_3f
local function str_is_python_expr_3f(s)
  local parser = vim.treesitter.get_string_parser(s, "python")
  local result = parser:parse()
  local tree = a.get(result, 1)
  local root = tree:root()
  return ((1 == root:child_count()) and is_expression_3f(root:child(0)))
end
_2amodule_2a["str-is-python-expr?"] = str_is_python_expr_3f
local function get_exec_str(s)
  return ("import base64\nexec(base64.b64decode('" .. b64.encode(s) .. "'))\n")
end
_2amodule_locals_2a["get-exec-str"] = get_exec_str
local function prep_code(s)
  local python_expr = str_is_python_expr_3f(s)
  if python_expr then
    return (s .. "\n")
  else
    return get_exec_str(s)
  end
end
_2amodule_locals_2a["prep-code"] = prep_code
local function is_dots_3f(s)
  return (string.sub(s, 1, 3) == "...")
end
_2amodule_locals_2a["is-dots?"] = is_dots_3f
local function format_msg(msg)
  local function _5_(_241)
    return not is_dots_3f(_241)
  end
  local function _6_(_241)
    return ("" ~= _241)
  end
  return a.filter(_5_, a.filter(_6_, text["split-lines"](msg)))
end
_2amodule_2a["format-msg"] = format_msg
local function get_console_output_msgs(msgs)
  local function _7_(_241)
    return (comment_prefix .. "(out) " .. _241)
  end
  return a.map(_7_, a.butlast(msgs))
end
_2amodule_locals_2a["get-console-output-msgs"] = get_console_output_msgs
local function get_expression_result(msgs)
  local result = a.last(msgs)
  if (a["nil?"](result) or is_dots_3f(result)) then
    return nil
  else
    return result
  end
end
_2amodule_locals_2a["get-expression-result"] = get_expression_result
local function unbatch(msgs)
  local function _9_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return str.join("", a.map(_9_, msgs))
end
_2amodule_2a["unbatch"] = unbatch
local function log_repl_output(msgs)
  local msgs0 = format_msg(unbatch(msgs))
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
_2amodule_locals_2a["log-repl-output"] = log_repl_output
local function eval_str(opts)
  local function _12_(repl)
    local function _13_(msgs)
      log_repl_output(msgs)
      if opts["on-result"] then
        local msgs0 = format_msg(unbatch(msgs))
        local cmd_result = get_expression_result(msgs0)
        return opts["on-result"](cmd_result)
      else
        return nil
      end
    end
    return repl.send(prep_code(opts.code), _13_, {["batch?"] = true})
  end
  return with_repl_or_warn(_12_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
end
_2amodule_2a["eval-file"] = eval_file
local function get_help(code)
  return str.join("", {"help(", str.trim(code), ")"})
end
_2amodule_2a["get-help"] = get_help
local function doc_str(opts)
  if str_is_python_expr_3f(opts.code) then
    return eval_str(a.assoc(opts, "code", get_help(opts.code)))
  else
    return nil
  end
end
_2amodule_2a["doc-str"] = doc_str
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  else
    return nil
  end
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
_2amodule_2a["stop"] = stop
local update_python_displayhook = str.join("\n", {"import sys", "def format_output(val):", "    print(repr(val))", "sys.displayhook = format_output\n"})
do end (_2amodule_2a)["update-python-displayhook"] = update_python_displayhook
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _18_()
      if vim.treesitter.language.require_language then
        return vim.treesitter.language.require_language("python")
      else
        return vim.treesitter.require_language("python")
      end
    end
    if not pcall(_18_) then
      return log.append({(comment_prefix .. "(error) The python client requires a python treesitter parser in order to function."), (comment_prefix .. "(error) See https://github.com/nvim-treesitter/nvim-treesitter"), (comment_prefix .. "(error) for installation instructions.")})
    else
      local function _20_()
        local function _21_(repl)
          local function _22_(msgs)
            return nil
          end
          return repl.send(prep_code(update_python_displayhook), _22_, nil)
        end
        return display_repl_status("started", with_repl_or_warn(_21_))
      end
      local function _23_(err)
        return display_repl_status(err)
      end
      local function _24_(code, signal)
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
      local function _27_(msg)
        return log.dbg(format_msg(unbatch({msg})), {["join-first?"] = true})
      end
      return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt-pattern"}), cmd = cfg({"command"}), ["delay-stderr-ms"] = cfg({"delay-stderr-ms"}), ["on-success"] = _20_, ["on-error"] = _23_, ["on-exit"] = _24_, ["on-stray-output"] = _27_}))
    end
  end
end
_2amodule_2a["start"] = start
local function on_load()
  if config["get-in"]({"client_on_load"}) then
    return start()
  else
    return log.append({"Not starting repl"})
  end
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit
local function interrupt()
  local function _31_(repl)
    local uv = vim.loop
    return uv.kill(repl.pid, uv.constants.SIGINT)
  end
  return with_repl_or_warn(_31_)
end
_2amodule_2a["interrupt"] = interrupt
local function on_filetype()
  mapping.buf("PythonStart", cfg({"mapping", "start"}), start, {desc = "Start the Python REPL"})
  mapping.buf("PythonStop", cfg({"mapping", "stop"}), stop, {desc = "Stop the Python REPL"})
  return mapping.buf("PythonInterrupt", cfg({"mapping", "interrupt"}), interrupt, {desc = "Interrupt the current evaluation"})
end
_2amodule_2a["on-filetype"] = on_filetype
return _2amodule_2a