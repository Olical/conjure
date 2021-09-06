local _2afile_2a = "fnl/conjure/extract.fnl"
local _2amodule_name_2a = "conjure.extract"
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
local a, client, config, nu, nvim, str, ts = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.nvim.util"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.tree-sitter")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nu"] = nu
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["ts"] = ts
local function read_range(_1_, _3_)
  local _arg_2_ = _1_
  local srow = _arg_2_[1]
  local scol = _arg_2_[2]
  local _arg_4_ = _3_
  local erow = _arg_4_[1]
  local ecol = _arg_4_[2]
  local lines = nvim.buf_get_lines(0, (srow - 1), erow, false)
  local function _5_(s)
    return string.sub(s, 0, ecol)
  end
  local function _6_(s)
    return string.sub(s, scol)
  end
  return str.join("\n", a.update(a.update(lines, #lines, _5_), 1, _6_))
end
_2amodule_locals_2a["read-range"] = read_range
local function current_char()
  local _let_7_ = nvim.win_get_cursor(0)
  local row = _let_7_[1]
  local col = _let_7_[2]
  local _let_8_ = nvim.buf_get_lines(0, (row - 1), row, false)
  local line = _let_8_[1]
  local char = (col + 1)
  return string.sub(line, char, char)
end
_2amodule_locals_2a["current-char"] = current_char
local function nil_pos_3f(pos)
  return (not pos or (0 == unpack(pos)))
end
_2amodule_locals_2a["nil-pos?"] = nil_pos_3f
local function skip_match_3f()
  local _let_9_ = nvim.win_get_cursor(0)
  local row = _let_9_[1]
  local col = _let_9_[2]
  local stack = nvim.fn.synstack(row, a.inc(col))
  local stack_size = #stack
  local function _10_()
    local name = nvim.fn.synIDattr(stack[stack_size], "name")
    return (name:find("Comment$") or name:find("String$") or name:find("Regexp%?$"))
  end
  if (("number" == type(((stack_size > 0) and _10_()))) or ("\\" == string.sub(a.first(nvim.buf_get_lines(nvim.win_get_buf(0), (row - 1), row, false)), col, col))) then
    return 1
  else
    return 0
  end
end
_2amodule_2a["skip-match?"] = skip_match_3f
local function form_2a(_12_, _14_)
  local _arg_13_ = _12_
  local start_char = _arg_13_[1]
  local end_char = _arg_13_[2]
  local escape_3f = _arg_13_[3]
  local _arg_15_ = _14_
  local root_3f = _arg_15_["root?"]
  local flags
  local function _16_()
    if root_3f then
      return "r"
    else
      return ""
    end
  end
  flags = ("Wnz" .. _16_())
  local cursor_char = current_char()
  local skip_match_3f_viml = "luaeval(\"require('conjure.extract')['skip-match?']()\")"
  local safe_start_char
  if escape_3f then
    safe_start_char = ("\\" .. start_char)
  else
    safe_start_char = start_char
  end
  local safe_end_char
  if escape_3f then
    safe_end_char = ("\\" .. end_char)
  else
    safe_end_char = end_char
  end
  local start
  local function _19_()
    if (cursor_char == start_char) then
      return "c"
    else
      return ""
    end
  end
  start = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. "b" .. _19_()), skip_match_3f_viml)
  local _end
  local function _20_()
    if (cursor_char == end_char) then
      return "c"
    else
      return ""
    end
  end
  _end = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. _20_()), skip_match_3f_viml)
  if (not nil_pos_3f(start) and not nil_pos_3f(_end)) then
    return {range = {start = a.update(start, 2, a.dec), ["end"] = a.update(_end, 2, a.dec)}, content = read_range(start, _end)}
  end
end
_2amodule_locals_2a["form*"] = form_2a
local function range_distance(range)
  local _let_22_ = range.start
  local sl = _let_22_[1]
  local sc = _let_22_[2]
  local _let_23_ = range["end"]
  local el = _let_23_[1]
  local ec = _let_23_[2]
  return {(sl - el), (sc - ec)}
end
_2amodule_locals_2a["range-distance"] = range_distance
local function distance_gt(_24_, _26_)
  local _arg_25_ = _24_
  local al = _arg_25_[1]
  local ac = _arg_25_[2]
  local _arg_27_ = _26_
  local bl = _arg_27_[1]
  local bc = _arg_27_[2]
  return ((al > bl) or ((al == bl) and (ac > bc)))
end
_2amodule_locals_2a["distance-gt"] = distance_gt
local function form(opts)
  if ts["enabled?"]() then
    local node
    if opts["root?"] then
      node = ts["get-root"]()
    else
      node = ts["get-form"]()
    end
    if node then
      return {range = ts.range(node), content = ts["node->str"](node)}
    end
  else
    local forms
    local function _30_(_241)
      return form_2a(_241, opts)
    end
    forms = a.filter(a["table?"], a.map(_30_, config["get-in"]({"extract", "form_pairs"})))
    local function _31_(_241, _242)
      return distance_gt(range_distance(_241.range), range_distance(_242.range))
    end
    table.sort(forms, _31_)
    if opts["root?"] then
      return a.last(forms)
    else
      return a.first(forms)
    end
  end
end
_2amodule_2a["form"] = form
local function word()
  return {content = nvim.fn.expand("<cword>"), range = {start = nvim.win_get_cursor(0), ["end"] = nvim.win_get_cursor(0)}}
end
_2amodule_2a["word"] = word
local function file_path()
  return nvim.fn.expand("%:p")
end
_2amodule_2a["file-path"] = file_path
local function buf_last_line_length(buf)
  return a.count(a.first(nvim.buf_get_lines(buf, a.dec(nvim.buf_line_count(buf)), -1, false)))
end
_2amodule_locals_2a["buf-last-line-length"] = buf_last_line_length
local function range(start, _end)
  return {content = str.join("\n", nvim.buf_get_lines(0, start, _end, false)), range = {start = {a.inc(start), 0}, ["end"] = {_end, buf_last_line_length(0)}}}
end
_2amodule_2a["range"] = range
local function buf()
  return range(0, -1)
end
_2amodule_2a["buf"] = buf
local function getpos(expr)
  local _let_34_ = nvim.fn.getpos(expr)
  local _ = _let_34_[1]
  local start = _let_34_[2]
  local _end = _let_34_[3]
  local _0 = _let_34_[4]
  return {start, a.dec(_end)}
end
_2amodule_locals_2a["getpos"] = getpos
local function selection(_35_)
  local _arg_36_ = _35_
  local kind = _arg_36_["kind"]
  local visual_3f = _arg_36_["visual?"]
  local sel_backup = nvim.o.selection
  nvim.ex.let("g:conjure_selection_reg_backup = @@")
  nvim.o.selection = "inclusive"
  if visual_3f then
    nu.normal(("`<" .. kind .. "`>y"))
  elseif (kind == "line") then
    nu.normal("'[V']y")
  elseif (kind == "block") then
    nu.normal("`[\22`]y")
  else
    nu.normal("`[v`]y")
  end
  local content = nvim.eval("@@")
  nvim.o.selection = sel_backup
  nvim.ex.let("@@ = g:conjure_selection_reg_backup")
  return {content = content, range = {start = getpos("'<"), ["end"] = getpos("'>")}}
end
_2amodule_2a["selection"] = selection
local function context()
  local pat = client.get("context-pattern")
  local f
  if pat then
    local function _38_(_241)
      return string.match(_241, pat)
    end
    f = _38_
  else
    f = client.get("context")
  end
  if f then
    return f(str.join("\n", nvim.buf_get_lines(0, 0, config["get-in"]({"extract", "context_header_lines"}), false)))
  end
end
_2amodule_2a["context"] = context
local function prompt(prefix)
  local ok_3f, val = nil, nil
  local function _41_()
    return nvim.fn.input((prefix or ""))
  end
  ok_3f, val = pcall(_41_)
  if ok_3f then
    return val
  end
end
_2amodule_2a["prompt"] = prompt
local function prompt_char()
  return nvim.fn.nr2char(nvim.fn.getchar())
end
_2amodule_2a["prompt-char"] = prompt_char