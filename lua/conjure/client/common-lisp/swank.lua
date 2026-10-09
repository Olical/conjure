-- [nfnl] fnl/conjure/client/common-lisp/swank.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local remote = autoload("conjure.remote.swank")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
local cmpl = autoload("conjure.client.common-lisp.completions")
local M = define("conjure.client.common-lisp.swank")
M["buf-suffix"] = ".lisp"
M["comment-prefix"] = "; "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
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
M.context = function(_code)
  local _let_3_ = vim.api.nvim_win_get_cursor(0)
  local line = _let_3_[1]
  local _col = _let_3_[2]
  local lines = vim.api.nvim_buf_get_lines(0, 0, line, false)
  local function _4_(line0)
    return (string.match(line0, "%(%s*defpackage%s+(.-)[%s){]") or string.match(line0, "%(%s*in%-package%s+(.-)[%s){]"))
  end
  return iterate_backwards(_4_, lines)
end
config.merge({client = {common_lisp = {swank = {connection = {default_host = "127.0.0.1", default_port = "4005"}, enable_completions = true}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {common_lisp = {swank = {mapping = {connect = "cc", disconnect = "cd", invoke_restart = "dr", macroexpand_1 = "m1", macroexpand_all = "ma"}}}}})
else
end
local state
local function _6_()
  return {conn = nil, ["eval-id"] = 0}
end
state = client["new-state"](_6_)
local function completions_enabled_3f()
  return config["get-in"]({"client", "common_lisp", "swank", "enable_completions"})
end
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
M.disconnect = function()
  local function _10_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return core.assoc(state(), "conn", nil)
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
local function send_rex(form, context, thread, cb)
  local function _11_(conn)
    local eval_id = core.get(core.update(state(), "eval-id", core.inc), "eval-id")
    return remote.send(conn, str.join({"(:emacs-rex ", form, " \"", (context or "*package*"), "\" ", thread, " ", eval_id, ")"}), cb)
  end
  return with_conn_or_warn(_11_)
end
local function send(msg, context, cb)
  log.dbg(("swank.send called with msg: " .. core["pr-str"](msg) .. ", context: " .. core["pr-str"](context)))
  return send_rex(("(swank:eval-and-grab-output \"" .. escape_string(msg) .. "\")"), context, "t", cb)
end
M.connect = function(opts)
  log.dbg(("connect called with: " .. core["pr-str"](opts)))
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_port"}))
  if state("conn") then
    M.disconnect()
  else
  end
  local function _13_(err)
    display_conn_status(err)
    return M.disconnect()
  end
  local function _14_()
    return display_conn_status("connected")
  end
  local function _15_(err)
    if err then
      return display_conn_status(err)
    else
      return M.disconnect()
    end
  end
  local function _17_(_241)
    return M["handle-event"](_241)
  end
  core.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _13_, ["on-success"] = _14_, ["on-error"] = _15_, ["on-event"] = _17_}))
  local function _18_(_)
  end
  return send(":ok", _18_)
end
local function try_ensure_conn()
  if not connected_3f() then
    return M.connect({["silent?"] = true})
  else
    return nil
  end
end
local function string_stream(str0)
  local index = 1
  local function _20_()
    local r = str0:byte(index)
    index = (index + 1)
    return r
  end
  return _20_
end
local function display_stdout(msg)
  if ((nil ~= msg) and ("" ~= msg)) then
    return log.append(text["prefixed-lines"](msg, M["comment-prefix"]))
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
        table.insert(vals, str.join(core.map(string.char, stack)))
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
M["parse-result"] = function(received)
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
M["eval-str"] = function(opts)
  log.dbg(("eval-str() called with: " .. core["pr-str"](opts)))
  try_ensure_conn()
  if not core["empty?"](opts.code) then
    local _31_
    if ("buf" == opts.origin) then
      _31_ = ("(list " .. opts.code .. ")")
    else
      _31_ = opts.code
    end
    local _33_
    if not core["empty?"](opts.context) then
      _33_ = opts.context
    else
      _33_ = nil
    end
    local function _35_(msg)
      local stdout, result = M["parse-result"](msg)
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
    return send(_31_, _33_, _35_)
  else
    return nil
  end
end
M["doc-str"] = function(opts)
  try_ensure_conn()
  local function _40_(_241)
    return ("(describe '" .. _241 .. ")")
  end
  return M["eval-str"](core.update(opts, "code", _40_))
end
local function split_list(s)
  local items = {}
  local cur = {}
  local depth = 0
  local in_str_3f = false
  local esc_3f = false
  local function flush()
    if (#cur > 0) then
      table.insert(items, table.concat(cur))
      for i = #cur, 1, -1 do
        cur[i] = nil
      end
      return nil
    else
      return nil
    end
  end
  for i = 1, #s do
    local c = string.sub(s, i, i)
    if in_str_3f then
      table.insert(cur, c)
      if esc_3f then
        esc_3f = false
      elseif (c == "\\") then
        esc_3f = true
      elseif (c == "\"") then
        in_str_3f = false
      else
      end
    elseif ((depth == 0) and (c == "(")) then
      depth = 1
    elseif ((depth == 1) and (c == ")")) then
      flush()
      depth = 0
    elseif ((depth == 1) and ((c == " ") or (c == "\n"))) then
      flush()
    elseif (depth > 0) then
      table.insert(cur, c)
      if (c == "\"") then
        in_str_3f = true
      elseif (c == "(") then
        depth = (depth + 1)
      elseif (c == ")") then
        depth = (depth - 1)
      else
      end
    else
    end
  end
  return items
end
local function append_commented(lines, s)
  for _, line in ipairs(text["prefixed-lines"](s, M["comment-prefix"])) do
    table.insert(lines, line)
  end
  return lines
end
local function show_debugger(_45_)
  local thread = _45_[1]
  local level = _45_[2]
  local condition = _45_[3]
  local restarts = _45_[4]
  local frames = _45_[5]
  core.assoc(state(), "debug", {thread = thread, level = level})
  local _let_46_ = parse_separated_list(condition)
  local msg = _let_46_[1]
  local kind = _let_46_[2]
  local rs = parse_separated_list(restarts)
  local lines = append_commented({}, ("Debugger level " .. level .. ": " .. msg))
  append_commented(lines, kind)
  table.insert(lines, "; Restarts:")
  for i = 1, #rs, 2 do
    append_commented(lines, (" " .. math.floor(((i - 1) / 2)) .. ": [" .. rs[i] .. "] " .. rs[(i + 1)]))
  end
  table.insert(lines, "; Backtrace:")
  for i, frame in ipairs(parse_separated_list(frames)) do
    append_commented(lines, (" " .. (i - 1) .. ": " .. frame))
  end
  return log.append(lines, {["break?"] = true})
end
M["handle-event"] = function(msg)
  local _let_47_ = split_list(msg)
  local kind = _let_47_[1]
  local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_47_, 2)
  if (kind == ":write-string") then
    return display_stdout(core.first(parse_separated_list(core.first(args))))
  elseif (kind == ":debug") then
    return show_debugger(args)
  elseif (kind == ":debug-return") then
    local level = tonumber(args[2])
    local function _48_()
      if (level > 1) then
        return {thread = args[1], level = (level - 1)}
      else
        return nil
      end
    end
    core.assoc(state(), "debug", _48_())
    return log.append({("; Left debugger level " .. level)})
  elseif (kind == ":ping") then
    local function _49_(_241)
      return remote.send(_241, ("(:emacs-pong " .. args[1] .. " " .. args[2] .. ")"))
    end
    return with_conn_or_warn(_49_)
  else
    return nil
  end
end
M["invoke-restart"] = function(n)
  local dbg = state("debug")
  if (dbg and n) then
    local function _51_(_)
    end
    return send_rex(("(swank:invoke-nth-restart-for-emacs " .. dbg.level .. " " .. n .. ")"), nil, dbg.thread, _51_)
  else
    return log.append({"; Not in the debugger"})
  end
end
local function unquote_lisp_string(s)
  return string.gsub(string.sub(s, 2, -2), "\\(.)", "%1")
end
M.macroexpand = function(swank_fn)
  local form = extract.form({})
  if form then
    local function _53_(result)
      return log.append(text["split-lines"](unquote_lisp_string(result)), {["break?"] = true})
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, context = M.context(), code = ("(swank:" .. swank_fn .. " \"" .. escape_string(form.content) .. "\")"), ["on-result"] = _53_})
  else
    return nil
  end
end
M["eval-file"] = function(opts)
  try_ensure_conn()
  return M["eval-str"](core.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
M["on-filetype"] = function()
  mapping.buf("CommonLispDisconnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "disconnect"}), M.disconnect, {desc = "Disconnect from the REPL"})
  local function _55_()
    return M.connect({})
  end
  mapping.buf("CommonLispConnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "connect"}), _55_, {desc = "Connect to a REPL"})
  local function _56_()
    return M["invoke-restart"](tonumber(vim.fn.input("Restart: ")))
  end
  mapping.buf("CommonLispInvokeRestart", config["get-in"]({"client", "common_lisp", "swank", "mapping", "invoke_restart"}), _56_, {desc = "Invoke a debugger restart by number"})
  local function _57_()
    return M.macroexpand("swank-macroexpand-1")
  end
  mapping.buf("CommonLispMacroexpand1", config["get-in"]({"client", "common_lisp", "swank", "mapping", "macroexpand_1"}), _57_, {desc = "Macroexpand the current form once"})
  local function _58_()
    return M.macroexpand("swank-macroexpand-all")
  end
  return mapping.buf("CommonLispMacroexpandAll", config["get-in"]({"client", "common_lisp", "swank", "mapping", "macroexpand_all"}), _58_, {desc = "Fully macroexpand the current form"})
end
M["on-load"] = function()
  if completions_enabled_3f() then
    cmpl["get-static-completions"]()
  else
  end
  return M.connect({})
end
M["on-exit"] = function()
  return M.disconnect()
end
local function build_completions_code(prefix, context)
  return ("(let ((r (swank:simple-completions " .. core["pr-str"](prefix) .. " " .. core["pr-str"](context) .. ")))" .. " (loop for e in (if (stringp (second r)) (mapcar #'list (first r)) r)" .. " append (list (first e) (or (second e) \"\"))))")
end
local kind_by_flag = {{"s", "special-operator"}, {"m", "macro"}, {"g", "generic-function"}, {"a", "accessor"}, {"f", "function"}, {"c", "class"}, {"t", "type"}, {"b", "variable"}, {"p", "package"}}
local function flags__3ekind(flags)
  local kind = nil
  for _, _60_ in ipairs(kind_by_flag) do
    local flag = _60_[1]
    local flag_kind = _60_[2]
    if kind then break end
    if string.find(flags, flag, 1, true) then
      kind = flag_kind
    else
      kind = nil
    end
  end
  return kind
end
M["parse-completions"] = function(result)
  local strs = parse_separated_list(result)
  local tbl_26_ = {}
  local i_27_ = 0
  for i = 1, #strs, 2 do
    local val_28_
    do
      local word = strs[i]
      local kind = flags__3ekind((strs[(i + 1)] or ""))
      if kind then
        val_28_ = {word = word, kind = kind}
      else
        val_28_ = word
      end
    end
    if (nil ~= val_28_) then
      i_27_ = (i_27_ + 1)
      tbl_26_[i_27_] = val_28_
    else
    end
  end
  return tbl_26_
end
local function completion_word(completion)
  if ("string" == type(completion)) then
    return completion
  else
    return completion.word
  end
end
local function merge_completions(static_completions, swank_completions)
  local swank_by_word
  do
    local tbl_21_ = {}
    for _, c in ipairs(swank_completions) do
      local k_22_, v_23_ = completion_word(c), c
      if ((k_22_ ~= nil) and (v_23_ ~= nil)) then
        tbl_21_[k_22_] = v_23_
      else
      end
    end
    swank_by_word = tbl_21_
  end
  local seen = {}
  local merged = {}
  for _, c in ipairs(core.concat(static_completions, swank_completions)) do
    local word = completion_word(c)
    if not seen[word] then
      seen[word] = true
      table.insert(merged, (swank_by_word[word] or c))
    else
    end
  end
  return merged
end
local function build_completions(opts)
  local prefix = (opts.prefix or "")
  local static_completions = cmpl["get-static-completions"](prefix)
  if connected_3f() then
    local code = build_completions_code(opts.prefix, opts.context)
    local result_fn
    local function _67_(results)
      local cmpl_list = merge_completions(static_completions, M["parse-completions"](results))
      return opts.cb(cmpl_list)
    end
    result_fn = _67_
    core.assoc(opts, "code", code)
    core.assoc(opts, "context", "COMMON-LISP-USER")
    core.assoc(opts, "on-result", result_fn)
    core.assoc(opts, "passive?", true)
    return M["eval-str"](opts)
  else
    return opts.cb(static_completions)
  end
end
M.completions = function(opts)
  if completions_enabled_3f() then
    return build_completions(opts)
  else
    return opts.cb({})
  end
end
return M
