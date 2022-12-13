local _2afile_2a = "fnl/conjure/text.fnl"
local _2amodule_name_2a = "conjure.text"
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
local a, str = require("conjure.aniseed.core"), require("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["str"] = str
local function trailing_newline_3f(s)
  return string.match(s, "\13?\n$")
end
_2amodule_2a["trailing-newline?"] = trailing_newline_3f
local function trim_last_newline(s)
  return string.gsub(s, "\13?\n$", "")
end
_2amodule_2a["trim-last-newline"] = trim_last_newline
local function left_sample(s, limit)
  local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
  if (limit >= a.count(flat)) then
    return flat
  else
    return (string.sub(flat, 0, a.dec(limit)) .. "...")
  end
end
_2amodule_2a["left-sample"] = left_sample
local function right_sample(s, limit)
  return string.reverse(left_sample(string.reverse(s), limit))
end
_2amodule_2a["right-sample"] = right_sample
local function split_lines(s)
  return str.split(s, "\13?\n")
end
_2amodule_2a["split-lines"] = split_lines
local function prefixed_lines(s, prefix, opts)
  local function _4_(_2_)
    local _arg_3_ = _2_
    local n = _arg_3_[1]
    local line = _arg_3_[2]
    if ((1 == n) and a.get(opts, "skip-first?")) then
      return line
    else
      return (prefix .. line)
    end
  end
  return a["map-indexed"](_4_, split_lines(s))
end
_2amodule_2a["prefixed-lines"] = prefixed_lines
local function starts_with(str0, start)
  if str0 then
    return (string.sub(str0, 1, a.count(start)) == start)
  else
    return nil
  end
end
_2amodule_2a["starts-with"] = starts_with
local function ends_with(str0, _end)
  if str0 then
    return ((_end == "") or (_end == string.sub(str0, ( - a.count(_end)))))
  else
    return nil
  end
end
_2amodule_2a["ends-with"] = ends_with
local function first_and_last_chars(str0)
  if str0 then
    if (a.count(str0) > 1) then
      return (string.sub(str0, 1, 1) .. string.sub(str0, -1, -1))
    else
      return str0
    end
  else
    return nil
  end
end
_2amodule_2a["first-and-last-chars"] = first_and_last_chars
local function strip_ansi_escape_sequences(s)
  return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
end
_2amodule_2a["strip-ansi-escape-sequences"] = strip_ansi_escape_sequences
local function chars(s)
  local res = {}
  if s then
    for c in string.gmatch(s, ".") do
      table.insert(res, c)
    end
  else
  end
  return res
end
_2amodule_2a["chars"] = chars
local function upper_first(s)
  if s then
    return s:gsub("^%l", string.upper)
  else
    return nil
  end
end
_2amodule_2a["upper-first"] = upper_first
return _2amodule_2a