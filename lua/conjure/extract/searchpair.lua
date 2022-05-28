local _2afile_2a = "fnl/conjure/extract/searchpair.fnl"
local _2amodule_name_2a = "conjure.extract.searchpair"
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
local a, config, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function nil_pos_3f(pos)
  return (not pos or (0 == unpack(pos)))
end
_2amodule_locals_2a["nil-pos?"] = nil_pos_3f
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
local function skip_match_3f()
  local _let_7_ = nvim.win_get_cursor(0)
  local row = _let_7_[1]
  local col = _let_7_[2]
  local stack = nvim.fn.synstack(row, a.inc(col))
  local stack_size = #stack
  local function _8_()
    local name = nvim.fn.synIDattr(stack[stack_size], "name")
    return (name:find("Comment$") or name:find("String$") or name:find("Regexp%?$"))
  end
  if (("number" == type(((stack_size > 0) and _8_()))) or ("\\" == string.sub(a.first(nvim.buf_get_lines(nvim.win_get_buf(0), (row - 1), row, false)), col, col))) then
    return 1
  else
    return 0
  end
end
_2amodule_2a["skip-match?"] = skip_match_3f
local function current_char()
  local _let_10_ = nvim.win_get_cursor(0)
  local row = _let_10_[1]
  local col = _let_10_[2]
  local _let_11_ = nvim.buf_get_lines(0, (row - 1), row, false)
  local line = _let_11_[1]
  local char = (col + 1)
  return string.sub(line, char, char)
end
_2amodule_locals_2a["current-char"] = current_char
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
  start = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. "b" .. _19_()), skip_match_3f)
  local _end
  local function _20_()
    if (cursor_char == end_char) then
      return "c"
    else
      return ""
    end
  end
  _end = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. _20_()), skip_match_3f)
  if (not nil_pos_3f(start) and not nil_pos_3f(_end)) then
    return {range = {start = {a.first(start), a.dec(a.second(start))}, ["end"] = {a.first(_end), a.dec(a.second(_end))}}, content = read_range(start, _end)}
  else
    return nil
  end
end
_2amodule_locals_2a["form*"] = form_2a
local function distance_gt(_22_, _24_)
  local _arg_23_ = _22_
  local al = _arg_23_[1]
  local ac = _arg_23_[2]
  local _arg_25_ = _24_
  local bl = _arg_25_[1]
  local bc = _arg_25_[2]
  return ((al > bl) or ((al == bl) and (ac > bc)))
end
_2amodule_locals_2a["distance-gt"] = distance_gt
local function range_distance(range)
  local _let_26_ = range.start
  local sl = _let_26_[1]
  local sc = _let_26_[2]
  local _let_27_ = range["end"]
  local el = _let_27_[1]
  local ec = _let_27_[2]
  return {(sl - el), (sc - ec)}
end
_2amodule_locals_2a["range-distance"] = range_distance
local function form(opts)
  local forms
  local function _28_(_241)
    return form_2a(_241, opts)
  end
  forms = a.filter(a["table?"], a.map(_28_, config["get-in"]({"extract", "form_pairs"})))
  local function _29_(_241, _242)
    return distance_gt(range_distance(_241.range), range_distance(_242.range))
  end
  table.sort(forms, _29_)
  if opts["root?"] then
    return a.last(forms)
  else
    return a.first(forms)
  end
end
_2amodule_2a["form"] = form
return _2amodule_2a