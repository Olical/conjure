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
local util = autoload("conjure.util")
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
  config.merge({client = {common_lisp = {swank = {mapping = {connect = "cc", disconnect = "cd", sticker_toggle = "ss", sticker_list = "sl", sticker_clear = "sc"}}}}})
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
local function send(msg, context, cb)
  log.dbg(("swank.send called with msg: " .. core["pr-str"](msg) .. ", context: " .. core["pr-str"](context)))
  local function _11_(conn)
    local eval_id = core.get(core.update(state(), "eval-id", core.inc), "eval-id")
    return remote.send(conn, str.join({"(:emacs-rex (swank:eval-and-grab-output \"", escape_string(msg), "\") \"", (context or "*package*"), "\" t ", eval_id, ")"}), cb)
  end
  return with_conn_or_warn(_11_)
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
  core.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _13_, ["on-success"] = _14_, ["on-error"] = _15_}))
  local function _17_(_)
  end
  return send(":ok", _17_)
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
  local function _19_()
    local r = str0:byte(index)
    index = (index + 1)
    return r
  end
  return _19_
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
local function sticker_key(id)
  return (":conjure-sticker-" .. vim.fn.getpid() .. "-" .. id)
end
local function stickers(buf)
  local function _31_(_30_)
    local id = _30_[1]
    local row = _30_[2]
    local col = _30_[3]
    local details = _30_[4]
    return {id = id, row = row, col = col, ["end-row"] = details.end_row, ["end-col"] = details.end_col}
  end
  return core.map(_31_, vim.api.nvim_buf_get_extmarks(buf, sticker_ns, 0, -1, {details = true}))
end
local function set_sticker(buf, s, label)
  return vim.api.nvim_buf_set_extmark(buf, sticker_ns, s.row, s.col, {id = s.id, end_row = s["end-row"], end_col = s["end-col"], hl_group = "Underlined", virt_text = {{label, "Comment"}}, virt_text_pos = "eol"})
end
M["instrument-stickers"] = function(buf, code, range)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local offset
  local function _32_(row, col)
    local o = col
    for r = 1, row do
      o = (o + #lines[r] + 1)
    end
    return o
  end
  offset = _32_
  local base = offset((core["get-in"](range, {"start", 1}) - 1), core["get-in"](range, {"start", 2}))
  local found
  local function _33_(s)
    return ((s.start >= 0) and (s["end"] <= #code) and (string.sub(code, (s.start + 1), s["end"]) == table.concat(vim.api.nvim_buf_get_text(buf, s.row, s.col, s["end-row"], s["end-col"], {}), "\n")))
  end
  local function _34_(s)
    return core.assoc(s, "start", (offset(s.row, s.col) - base), "end", (offset(s["end-row"], s["end-col"]) - base))
  end
  found = core.filter(_33_, core.map(_34_, stickers(buf)))
  local function _35_(_241, _242)
    return (_241.start > _242.start)
  end
  table.sort(found, _35_)
  local out = code
  for i, s in ipairs(found) do
    local label = (7000000 + s.id)
    local pre = ("(let ((#" .. label .. "=#:v (multiple-value-list ")
    local post = ("))) (push #" .. label .. "# (get " .. sticker_key(s.id) .. " :values)) (values-list #" .. label .. "#))")
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
  local function _37_(s)
    local _38_
    if all_3f then
      _38_ = " (format nil \"~{~{~S~^ ~}~^ | ~}\" v)"
    else
      _38_ = " (format nil \"~{~S~^ ~}\" (car (last v)))"
    end
    return ("(let ((v (reverse (get " .. sticker_key(s.id) .. " :values))))" .. " (format nil \"~D ~D ~A\" " .. s.id .. " (length v)" .. _38_ .. "))")
  end
  return ("(list " .. table.concat(core.map(_37_, stickers(buf)), " ") .. ")")
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
    local function _41_(result)
      local by_id
      local function _42_(acc, s)
        return core.assoc(acc, s.id, s)
      end
      by_id = core.reduce(_42_, {}, stickers(buf))
      local function _43_(id, n, vals)
        local s = by_id[id]
        if s then
          local function _44_()
            if (0 == n) then
              return "=> (no value yet)"
            else
              return ("=> " .. vals .. " (" .. n .. "x)")
            end
          end
          return set_sticker(buf, s, _44_())
        else
          return nil
        end
      end
      return each_sticker_result(result, _43_)
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, code = sticker_values_code(buf, false), ["on-result"] = _41_})
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
    local function _47_(_241)
      return ((row == _241.row) and (col == _241.col))
    end
    here = core.filter(_47_, stickers(buf))
    if core["empty?"](here) then
      local lines = text["split-lines"](form.content)
      local end_row = (row + #lines + -1)
      local end_col
      local _48_
      if (1 == #lines) then
        _48_ = col
      else
        _48_ = 0
      end
      end_col = (_48_ + #core.last(lines))
      return vim.api.nvim_buf_set_extmark(buf, sticker_ns, row, col, {end_row = end_row, end_col = end_col, hl_group = "Underlined", virt_text = {{"=> (no value yet)", "Comment"}}, virt_text_pos = "eol"})
    else
      return vim.api.nvim_buf_del_extmark(buf, sticker_ns, here[1].id)
    end
  else
    return nil
  end
end
M["clear-stickers"] = function()
  return vim.api.nvim_buf_clear_namespace(0, sticker_ns, 0, -1)
end
M["list-stickers"] = function()
  local buf = vim.api.nvim_get_current_buf()
  local by_id
  local function _52_(acc, s)
    return core.assoc(acc, s.id, s)
  end
  by_id = core.reduce(_52_, {}, stickers(buf))
  if core["empty?"](by_id) then
    return log.append({"; No stickers in this buffer"})
  else
    local function _53_(result)
      local lines = {"; Stickers"}
      local function _54_(id, n, vals)
        local s = by_id[id]
        if s then
          table.insert(lines, ("; line " .. (s.row + 1) .. " " .. table.concat(vim.api.nvim_buf_get_text(buf, s.row, s.col, s["end-row"], s["end-col"], {}), " ")))
          return table.insert(lines, (";   " .. n .. " pass(es): " .. vals))
        else
          return nil
        end
      end
      each_sticker_result(result, _54_)
      return log.append(lines, {["break?"] = true})
    end
    return M["eval-str"]({origin = "custom", ["passive?"] = true, code = sticker_values_code(buf, true), ["on-result"] = _53_})
  end
end
M["eval-str"] = function(opts)
  log.dbg(("eval-str() called with: " .. core["pr-str"](opts)))
  try_ensure_conn()
  if not core["empty?"](opts.code) then
    local buf = vim.api.nvim_get_current_buf()
    local code
    if opts.range then
      code = M["instrument-stickers"](buf, opts.code, opts.range)
    else
      code = opts.code
    end
    local _58_
    if ("buf" == opts.origin) then
      _58_ = ("(list " .. code .. ")")
    else
      _58_ = code
    end
    local _60_
    if not core["empty?"](opts.context) then
      _60_ = opts.context
    else
      _60_ = nil
    end
    local function _62_(msg)
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
    return send(_58_, _60_, _62_)
  else
    return nil
  end
end
M["doc-str"] = function(opts)
  try_ensure_conn()
  local function _67_(_241)
    return ("(describe '" .. _241 .. ")")
  end
  return M["eval-str"](core.update(opts, "code", _67_))
end
M["eval-file"] = function(opts)
  try_ensure_conn()
  return M["eval-str"](core.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
M["on-filetype"] = function()
  mapping.buf("CommonLispDisconnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "disconnect"}), M.disconnect, {desc = "Disconnect from the REPL"})
  local function _68_()
    return M.connect({})
  end
  mapping.buf("CommonLispConnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "connect"}), _68_, {desc = "Connect to a REPL"})
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
  return ("(swank:simple-completions " .. core["pr-str"](prefix) .. " " .. core["pr-str"](context) .. ")")
end
local function format_for_cmpl(rs)
  local cmpls = parse_separated_list(rs)
  table.remove(cmpls)
  return cmpls
end
local function build_completions(opts)
  local prefix = (opts.prefix or "")
  local static_completions = cmpl["get-static-completions"](prefix)
  if connected_3f() then
    local code = build_completions_code(opts.prefix, opts.context)
    local result_fn
    local function _70_(results)
      local parsed_results = format_for_cmpl(results)
      local all_cmpl = core.concat(static_completions, parsed_results)
      local cmpl_list = util["ordered-distinct"](all_cmpl)
      return opts.cb(cmpl_list)
    end
    result_fn = _70_
    core.assoc(opts, "code", code)
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
