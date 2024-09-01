-- [nfnl] Compiled from fnl/conjure/extract/searchpair.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local config = autoload("conjure.config")
local function nil_pos_3f(pos)
  return (not pos or (0 == unpack(pos)))
end
local function read_range(_2_, _3_)
  local srow = _2_[1]
  local scol = _2_[2]
  local erow = _3_[1]
  local ecol = _3_[2]
  local lines = vim.api.nvim_buf_get_lines(0, (srow - 1), erow, false)
  local function _4_(s)
    return string.sub(s, 0, ecol)
  end
  local function _5_(s)
    return string.sub(s, scol)
  end
  return str.join("\n", a.update(a.update(lines, #lines, _4_), 1, _5_))
end
local function skip_match_3f()
  local _let_6_ = vim.api.nvim_win_get_cursor(0)
  local row = _let_6_[1]
  local col = _let_6_[2]
  local stack = vim.fn.synstack(row, a.inc(col))
  local stack_size = #stack
  local and_7_ = (stack_size > 0)
  if and_7_ then
    local name = vim.fn.synIDattr(stack[stack_size], "name")
    and_7_ = (name:find("Comment$") or name:find("String$") or name:find("Regexp%?$"))
  end
  local or_9_ = ("number" == type(and_7_))
  if not or_9_ then
    or_9_ = ("\\" == string.sub(a.first(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(0), (row - 1), row, false)), col, col))
  end
  if or_9_ then
    return 1
  else
    return 0
  end
end
local function current_char()
  local _let_11_ = vim.api.nvim_win_get_cursor(0)
  local row = _let_11_[1]
  local col = _let_11_[2]
  local _let_12_ = vim.api.nvim_buf_get_lines(0, (row - 1), row, false)
  local line = _let_12_[1]
  local char = (col + 1)
  return string.sub(line, char, char)
end
local function form_2a(_13_, _14_)
  local start_char = _13_[1]
  local end_char = _13_[2]
  local escape_3f = _13_[3]
  local root_3f = _14_["root?"]
  local flags
  local _15_
  if root_3f then
    _15_ = "r"
  else
    _15_ = ""
  end
  flags = ("Wnz" .. _15_)
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
  local _19_
  if (cursor_char == start_char) then
    _19_ = "c"
  else
    _19_ = ""
  end
  start = vim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. "b" .. _19_), skip_match_3f)
  local _end
  local _21_
  if (cursor_char == end_char) then
    _21_ = "c"
  else
    _21_ = ""
  end
  _end = vim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. _21_), skip_match_3f)
  if (not nil_pos_3f(start) and not nil_pos_3f(_end)) then
    return {range = {start = {a.first(start), a.dec(a.second(start))}, ["end"] = {a.first(_end), a.dec(a.second(_end))}}, content = read_range(start, _end)}
  else
    return nil
  end
end
local function distance_gt(_24_, _25_)
  local al = _24_[1]
  local ac = _24_[2]
  local bl = _25_[1]
  local bc = _25_[2]
  return ((al > bl) or ((al == bl) and (ac > bc)))
end
local function range_distance(range)
  local sl = range.start[1]
  local sc = range.start[2]
  local el = range["end"][1]
  local ec = range["end"][2]
  return {(sl - el), (sc - ec)}
end
local function form(opts)
  local forms
  local function _26_(_241)
    return form_2a(_241, opts)
  end
  forms = a.filter(a["table?"], a.map(_26_, config["get-in"]({"extract", "form_pairs"})))
  local function _27_(_241, _242)
    return distance_gt(range_distance(_241.range), range_distance(_242.range))
  end
  table.sort(forms, _27_)
  if opts["root?"] then
    return a.last(forms)
  else
    return a.first(forms)
  end
end
return {["skip-match?"] = skip_match_3f, form = form}
