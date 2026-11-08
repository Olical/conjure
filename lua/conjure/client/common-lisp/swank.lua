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
  config.merge({client = {common_lisp = {swank = {mapping = {connect = "cc", disconnect = "cd", invoke_restart = "dr", macroexpand_1 = "m1", macroexpand_all = "ma", sticker_toggle = "ss", sticker_list = "sl", sticker_clear = "sc"}}}}})
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
local sticker_ns = vim.api.nvim_create_namespace("conjure-common-lisp-stickers")
local function sticker_key(buf, id)
  return (":conjure-sticker-" .. vim.fn.getpid() .. "-" .. buf .. "-" .. id)
end
local sticker_context = "COMMON-LISP-USER"
local function stickers(buf)
  local function _32_(_31_)
    local id = _31_[1]
    local row = _31_[2]
    local col = _31_[3]
    local details = _31_[4]
    return {id = id, row = row, col = col, ["end-row"] = details.end_row, ["end-col"] = details.end_col}
  end
  return core.map(_32_, vim.api.nvim_buf_get_extmarks(buf, sticker_ns, 0, -1, {details = true}))
end
local function set_sticker(buf, s, label)
  return vim.api.nvim_buf_set_extmark(buf, sticker_ns, s.row, s.col, {id = s.id, end_row = s["end-row"], end_col = s["end-col"], hl_group = "Underlined", virt_text = {{label, "Comment"}}, virt_text_pos = "eol"})
end
M["instrument-stickers"] = function(buf, code, range)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local offset
  local function _33_(row, col)
    local o = col
    for r = 1, row do
      o = (o + #lines[r] + 1)
    end
    return o
  end
  offset = _33_
  local base = offset((core["get-in"](range, {"start", 1}) - 1), core["get-in"](range, {"start", 2}))
  local found
  local function _34_(s)
    return ((s.start >= 0) and (s["end"] <= #code) and (string.sub(code, (s.start + 1), s["end"]) == table.concat(vim.api.nvim_buf_get_text(buf, s.row, s.col, s["end-row"], s["end-col"], {}), "\n")))
  end
  local function _35_(s)
    return core.assoc(s, "start", (offset(s.row, s.col) - base), "end", (offset(s["end-row"], s["end-col"]) - base))
  end
  found = core.filter(_34_, core.map(_35_, stickers(buf)))
  local function _36_(_241, _242)
    return (_241.start > _242.start)
  end
  table.sort(found, _36_)
  local out = code
  for i, s in ipairs(found) do
    local label = (7000000 + s.id)
    local pre = ("(cl:let ((#" .. label .. "=#:v (cl:multiple-value-list ")
    local post = ("))) (cl:push #" .. label .. "# (cl:get " .. sticker_key(buf, s.id) .. " :values)) (cl:values-list #" .. label .. "#))")
    out = (string.sub(out, 1, s.start) .. pre .. string.sub(out, (s.start + 1), s["end"]) .. post .. string.sub(out, (s["end"] + 1)))
    for j = (i + 1), #found do
      local outer = found[j]
      if (outer["end"] >= s["end"]) then
        outer["end"] = (outer["end"] + #pre + #post)
      else
      end
    end
  end
  return out
end
local function sticker_values_code(buf, all_3f)
  local function _38_(s)
    local _39_
    if all_3f then
      _39_ = " (format nil \"~{~{~S~^ ~}~^ | ~}\" v)"
    else
      _39_ = " (format nil \"~{~S~^ ~}\" (car (last v)))"
    end
    return ("(let ((v (reverse (get " .. sticker_key(buf, s.id) .. " :values))))" .. " (format nil \"~D ~D ~A\" " .. s.id .. " (length v)" .. _39_ .. "))")
  end
  return ("(list " .. table.concat(core.map(_38_, stickers(buf)), " ") .. ")")
end
local function forget_sticker_values(buf, ids)
  if (connected_3f() and not core["empty?"](ids)) then
    local function _41_(_241)
      return ("(remprop " .. sticker_key(buf, _241) .. " :values)")
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, context = sticker_context, code = ("(progn " .. table.concat(core.map(_41_, ids), " ") .. " nil)")})
  else
    return nil
  end
end
local function each_sticker_result(result, f)
  for _, entry in ipairs(parse_separated_list(result)) do
    local id, n, vals = string.match(entry, "^(%d+) (%d+) ?(.*)$")
    if id then
      f(tonumber(id), tonumber(n), vals)
    else
    end
  end
  return nil
end
M["refresh-stickers"] = function(buf)
  if not core["empty?"](stickers(buf)) then
    local function _44_(result)
      local by_id
      local function _45_(acc, s)
        return core.assoc(acc, s.id, s)
      end
      by_id = core.reduce(_45_, {}, stickers(buf))
      local function _46_(id, n, vals)
        local s = by_id[id]
        if s then
          local function _47_()
            if (0 == n) then
              return "=> (no value yet)"
            else
              return ("=> " .. vals .. " (" .. n .. "x)")
            end
          end
          return set_sticker(buf, s, _47_())
        else
          return nil
        end
      end
      return each_sticker_result(result, _46_)
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, context = sticker_context, code = sticker_values_code(buf, false), ["on-result"] = _44_})
  else
    return nil
  end
end
M["toggle-sticker"] = function()
  local form = extract.form({})
  local buf = vim.api.nvim_get_current_buf()
  if form then
    local row = (core["get-in"](form, {"range", "start", 1}) - 1)
    local col = core["get-in"](form, {"range", "start", 2})
    local here
    local function _50_(_241)
      return ((row == _241.row) and (col == _241.col))
    end
    here = core.filter(_50_, stickers(buf))
    if core["empty?"](here) then
      local lines = text["split-lines"](form.content)
      local end_row = (row + #lines + -1)
      local end_col
      local _51_
      if (1 == #lines) then
        _51_ = col
      else
        _51_ = 0
      end
      end_col = (_51_ + #core.last(lines))
      return vim.api.nvim_buf_set_extmark(buf, sticker_ns, row, col, {end_row = end_row, end_col = end_col, hl_group = "Underlined", virt_text = {{"=> (no value yet)", "Comment"}}, virt_text_pos = "eol"})
    else
      local id = here[1].id
      vim.api.nvim_buf_del_extmark(buf, sticker_ns, id)
      return forget_sticker_values(buf, {id})
    end
  else
    return nil
  end
end
M["clear-stickers"] = function()
  local buf = vim.api.nvim_get_current_buf()
  local function _55_(_241)
    return _241.id
  end
  forget_sticker_values(buf, core.map(_55_, stickers(buf)))
  return vim.api.nvim_buf_clear_namespace(buf, sticker_ns, 0, -1)
end
M["list-stickers"] = function()
  local buf = vim.api.nvim_get_current_buf()
  local by_id
  local function _56_(acc, s)
    return core.assoc(acc, s.id, s)
  end
  by_id = core.reduce(_56_, {}, stickers(buf))
  if core["empty?"](by_id) then
    return log.append({"; No stickers in this buffer"})
  else
    local function _57_(result)
      local lines = {"; Stickers"}
      local function _58_(id, n, vals)
        local s = by_id[id]
        if s then
          table.insert(lines, ("; line " .. (s.row + 1) .. " " .. table.concat(vim.api.nvim_buf_get_text(buf, s.row, s.col, s["end-row"], s["end-col"], {}), " ")))
          return table.insert(lines, (";   " .. n .. " pass(es): " .. vals))
        else
          return nil
        end
      end
      each_sticker_result(result, _58_)
      return log.append(lines, {["break?"] = true})
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, context = sticker_context, code = sticker_values_code(buf, true), ["on-result"] = _57_})
  end
end
M["eval-str"] = function(opts)
  log.dbg(("eval-str() called with: " .. core["pr-str"](opts)))
  try_ensure_conn()
  if not core["empty?"](opts.code) then
    local buf = vim.api.nvim_get_current_buf()
    local code
    if (opts.range and not core["empty?"](stickers(buf))) then
      code = M["instrument-stickers"](buf, opts.code, opts.range)
    else
      code = opts.code
    end
    local _62_
    if ("buf" == opts.origin) then
      _62_ = ("(list " .. code .. ")")
    else
      _62_ = code
    end
    local _64_
    if not core["empty?"](opts.context) then
      _64_ = opts.context
    else
      _64_ = nil
    end
    local function _66_(msg)
      local stdout, result = M["parse-result"](msg)
      display_stdout(stdout)
      if (nil ~= result) then
        if opts["on-result"] then
          opts["on-result"](result)
        else
        end
        if not opts["passive?"] then
          log.append(text["split-lines"](result))
          return M["refresh-stickers"](buf)
        else
          return nil
        end
      else
        return nil
      end
    end
    return send(_62_, _64_, _66_)
  else
    return nil
  end
end
M["doc-str"] = function(opts)
  try_ensure_conn()
  local function _71_(_241)
    return ("(describe '" .. _241 .. ")")
  end
  return M["eval-str"](core.update(opts, "code", _71_))
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
local function show_debugger(_76_)
  local thread = _76_[1]
  local level = _76_[2]
  local condition = _76_[3]
  local restarts = _76_[4]
  local frames = _76_[5]
  core.assoc(state(), "debug", {thread = thread, level = level})
  local _let_77_ = parse_separated_list(condition)
  local msg = _let_77_[1]
  local kind = _let_77_[2]
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
  local _let_78_ = split_list(msg)
  local kind = _let_78_[1]
  local args = (function (t, k) return ((getmetatable(t) or {}).__fennelrest or function (t, k) return {(table.unpack or unpack)(t, k)} end)(t, k) end)(_let_78_, 2)
  if (kind == ":write-string") then
    return display_stdout(core.first(parse_separated_list(core.first(args))))
  elseif (kind == ":debug") then
    return show_debugger(args)
  elseif (kind == ":debug-return") then
    local level = tonumber(args[2])
    local function _79_()
      if (level > 1) then
        return {thread = args[1], level = (level - 1)}
      else
        return nil
      end
    end
    core.assoc(state(), "debug", _79_())
    return log.append({("; Left debugger level " .. level)})
  elseif (kind == ":ping") then
    local function _80_(_241)
      return remote.send(_241, ("(:emacs-pong " .. args[1] .. " " .. args[2] .. ")"))
    end
    return with_conn_or_warn(_80_)
  else
    return nil
  end
end
M["invoke-restart"] = function(n)
  local dbg = state("debug")
  if (dbg and n) then
    local function _82_(_)
    end
    return send_rex(("(swank:invoke-nth-restart-for-emacs " .. dbg.level .. " " .. n .. ")"), nil, dbg.thread, _82_)
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
    local function _84_(result)
      return log.append(text["split-lines"](unquote_lisp_string(result)), {["break?"] = true})
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, context = M.context(), code = ("(swank:" .. swank_fn .. " \"" .. escape_string(form.content) .. "\")"), ["on-result"] = _84_})
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
  local function _86_()
    return M.connect({})
  end
  mapping.buf("CommonLispConnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "connect"}), _86_, {desc = "Connect to a REPL"})
  local function _87_()
    return M["invoke-restart"](tonumber(vim.fn.input("Restart: ")))
  end
  mapping.buf("CommonLispInvokeRestart", config["get-in"]({"client", "common_lisp", "swank", "mapping", "invoke_restart"}), _87_, {desc = "Invoke a debugger restart by number"})
  local function _88_()
    return M.macroexpand("swank-macroexpand-1")
  end
  mapping.buf("CommonLispMacroexpand1", config["get-in"]({"client", "common_lisp", "swank", "mapping", "macroexpand_1"}), _88_, {desc = "Macroexpand the current form once"})
  local function _89_()
    return M.macroexpand("swank-macroexpand-all")
  end
  mapping.buf("CommonLispMacroexpandAll", config["get-in"]({"client", "common_lisp", "swank", "mapping", "macroexpand_all"}), _89_, {desc = "Fully macroexpand the current form"})
  mapping.buf("CommonLispStickerToggle", config["get-in"]({"client", "common_lisp", "swank", "mapping", "sticker_toggle"}), M["toggle-sticker"], {desc = "Toggle a sticker on the current form"})
  mapping.buf("CommonLispStickerList", config["get-in"]({"client", "common_lisp", "swank", "mapping", "sticker_list"}), M["list-stickers"], {desc = "Log every value recorded by the stickers"})
  return mapping.buf("CommonLispStickerClear", config["get-in"]({"client", "common_lisp", "swank", "mapping", "sticker_clear"}), M["clear-stickers"], {desc = "Remove all stickers from the buffer"})
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
  for _, _91_ in ipairs(kind_by_flag) do
    local flag = _91_[1]
    local flag_kind = _91_[2]
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
    local function _98_(results)
      local cmpl_list = merge_completions(static_completions, M["parse-completions"](results))
      return opts.cb(cmpl_list)
    end
    result_fn = _98_
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
