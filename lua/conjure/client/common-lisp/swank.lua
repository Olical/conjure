-- [nfnl] Compiled from fnl/conjure/client/common-lisp/swank.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local remote = autoload("conjure.remote.swank")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
local util = autoload("conjure.util")
local buf_suffix = ".lisp"
local comment_prefix = "; "
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
local function iterate_backwards(f, lines)
  for i = #lines, 1, ( - 1) do
    local line = lines[i]
    local res = f(line)
    if res then
      return res
    else
    end
  end
  return nil
end
local function context(_code)
  local _let_3_ = vim.api.nvim_win_get_cursor(0)
  local line = _let_3_[1]
  local _col = _let_3_[2]
  local lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
  local function _4_(line0)
    return (string.match(line0, "%(%s*defpackage%s+(.-)[%s){]") or string.match(line0, "%(%s*in%-package%s+(.-)[%s){]"))
  end
  return iterate_backwards(_4_, lines)
end
config.merge({client = {common_lisp = {swank = {connection = {default_host = "127.0.0.1", default_port = "4005"}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {common_lisp = {swank = {mapping = {connect = "cc", disconnect = "cd"}}}}})
else
end
local state
local function _6_()
  return {conn = nil, ["eval-id"] = 0}
end
state = client["new-state"](_6_)
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append("; No connection")
  end
end
local function connected_3f()
  if state("conn") then
    return true
  else
    return false
  end
end
local function display_conn_status(status)
  local function _9_(conn)
    return log.append({("; " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
  end
  return with_conn_or_warn(_9_)
end
local function disconnect()
  local function _10_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return a.assoc(state(), "conn", nil)
  end
  return with_conn_or_warn(_10_)
end
local function escape_string(_in)
  local function replace(_in0, pat, rep)
    local s, c = string.gsub(_in0, pat, rep)
    return s
  end
  return replace(replace(_in, "\\", "\\\\"), "\"", "\\\"")
end
local function send(msg, context0, cb)
  log.dbg(("swank.send called with msg: " .. a["pr-str"](msg) .. ", context: " .. a["pr-str"](context0)))
  local function _11_(conn)
    local eval_id = a.get(a.update(state(), "eval-id", a.inc), "eval-id")
    return remote.send(conn, str.join({"(:emacs-rex (swank:eval-and-grab-output \"", escape_string(msg), "\") \"", (context0 or "*package*"), "\" t ", eval_id, ")"}), cb)
  end
  return with_conn_or_warn(_11_)
end
local function connect(opts)
  log.dbg(("connect called with: " .. a["pr-str"](opts)))
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_port"}))
  if state("conn") then
    disconnect()
  else
  end
  local function _13_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _14_()
    return display_conn_status("connected")
  end
  local function _15_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  a.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _13_, ["on-success"] = _14_, ["on-error"] = _15_}))
  local function _17_(_)
  end
  return send(":ok", _17_)
end
local function try_ensure_conn()
  if not connected_3f() then
    return connect({["silent?"] = true})
  else
    return nil
  end
end
local function string_stream(str0)
  local index = 1
  local function _19_()
    local r = str0:byte(index)
    index = (index + 1)
    return r
  end
  return _19_
end
local function display_stdout(msg)
  if ((nil ~= msg) and ("" ~= msg)) then
    return log.append(text["prefixed-lines"](msg, comment_prefix))
  else
    return nil
  end
end
local function inner_results(received)
  local search_string = "(:return (:ok ("
  local tail_size = 5
  local idx, len = string.find(received, search_string, 1, true)
  return string.sub(received, (idx + len), (string.len(received) - tail_size))
end
local function parse_separated_list(string_to_parse)
  local opened_quote = nil
  local escaped = false
  local stack = {}
  local vals = {}
  local slash_byte = string.byte("\\")
  local quote_byte = string.byte("\"")
  local function maybe_insert(b)
    if opened_quote then
      table.insert(stack, b)
      escaped = false
      return nil
    else
      return nil
    end
  end
  local function maybe_close(b)
    if opened_quote then
      if not escaped then
        opened_quote = false
        table.insert(vals, str.join(a.map(string.char, stack)))
        stack = {}
      else
      end
      if escaped then
        return maybe_insert(b)
      else
        return nil
      end
    else
      if escaped then
        log.dbg("Received an escaped quote outside of expected values")
      else
      end
      opened_quote = true
      return nil
    end
  end
  local function slash_escape(b)
    if escaped then
      return maybe_insert(b)
    else
      escaped = true
      return nil
    end
  end
  local function dispatch(b)
    if (b == slash_byte) then
      return slash_escape(b)
    elseif (b == quote_byte) then
      return maybe_close(b)
    else
      local _ = b
      return maybe_insert(b)
    end
  end
  for b in string_stream(string_to_parse) do
    dispatch(b)
  end
  return vals
end
local function parse_result(received)
  local function result_3f(response)
    return text["starts-with"](response, "(:return (:ok (")
  end
  if not result_3f(received) then
    local msg = (parse_separated_list(received))
    display_stdout(msg[1])
  else
  end
  if result_3f(received) then
    return unpack(parse_separated_list(inner_results(received)))
  else
    return nil
  end
end
local function eval_str(opts)
  log.dbg(("eval-str() called with: " .. a["pr-str"](opts)))
  try_ensure_conn()
  if not a["empty?"](opts.code) then
    local _30_
    if not a["empty?"](opts.context) then
      _30_ = opts.context
    else
      _30_ = nil
    end
    local function _32_(msg)
      local stdout, result = parse_result(msg)
      display_stdout(stdout)
      if (nil ~= result) then
        if opts["on-result"] then
          opts["on-result"](result)
        else
        end
        if not opts["passive?"] then
          return log.append(text["split-lines"](result))
        else
          return nil
        end
      else
        return nil
      end
    end
    return send(opts.code, _30_, _32_)
  else
    return nil
  end
end
local function doc_str(opts)
  try_ensure_conn()
  local function _37_(_241)
    return ("(describe '" .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _37_))
end
local function eval_file(opts)
  try_ensure_conn()
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function on_filetype()
  mapping.buf("CommonLispDisconnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "disconnect"}), disconnect, {desc = "Disconnect from the REPL"})
  local function _38_()
    return connect({})
  end
  return mapping.buf("CommonLispConnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "connect"}), _38_, {desc = "Connect to a REPL"})
end
local function on_load()
  return connect({})
end
local function on_exit()
  return disconnect()
end
local function completions(opts)
  try_ensure_conn()
  local code = ("(swank:simple-completions " .. a["pr-str"](opts.prefix) .. " " .. a["pr-str"](opts.context) .. ")")
  local format_for_cmpl
  local function _39_(rs)
    local cmpls = parse_separated_list(rs)
    local last = table.remove(cmpls)
    table.insert(cmpls, 1, last)
    return cmpls
  end
  format_for_cmpl = _39_
  local result_fn
  local function _40_(results)
    local cmpl_list = format_for_cmpl(results)
    return opts.cb(cmpl_list)
  end
  result_fn = _40_
  a.assoc(opts, "code", code)
  a.assoc(opts, "on-result", result_fn)
  a.assoc(opts, "passive?", true)
  return eval_str(opts)
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, context = context, disconnect = disconnect, connect = connect, ["parse-result"] = parse_result, ["eval-str"] = eval_str, ["doc-str"] = doc_str, ["eval-file"] = eval_file, ["on-filetype"] = on_filetype, ["on-load"] = on_load, ["on-exit"] = on_exit, completions = completions}
