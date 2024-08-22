-- [nfnl] Compiled from fnl/conjure/text.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local function trailing_newline_3f(s)
  return string.match(s, "\13?\n$")
end
local function trim_last_newline(s)
  return string.gsub(s, "\13?\n$", "")
end
local function left_sample(s, limit)
  local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
  if (limit >= a.count(flat)) then
    return flat
  else
    return (string.sub(flat, 0, a.dec(limit)) .. "...")
  end
end
local function right_sample(s, limit)
  return string.reverse(left_sample(string.reverse(s), limit))
end
local function split_lines(s)
  return str.split(s, "\13?\n")
end
local function prefixed_lines(s, prefix, opts)
  local function _4_(_3_)
    local n = _3_[1]
    local line = _3_[2]
    if ((1 == n) and a.get(opts, "skip-first?")) then
      return line
    else
      return (prefix .. line)
    end
  end
  return a["map-indexed"](_4_, split_lines(s))
end
local function starts_with(str0, start)
  if str0 then
    return (string.sub(str0, 1, a.count(start)) == start)
  else
    return nil
  end
end
local function ends_with(str0, _end)
  if str0 then
    return ((_end == "") or (_end == string.sub(str0, ( - a.count(_end)))))
  else
    return nil
  end
end
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
local function strip_ansi_escape_sequences(s)
  return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
end
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
local function upper_first(s)
  if s then
    return s:gsub("^%l", string.upper)
  else
    return nil
  end
end
return {["trailing-newline?"] = trailing_newline_3f, ["trim-last-newline"] = trim_last_newline, ["left-sample"] = left_sample, ["right-sample"] = right_sample, ["split-lines"] = split_lines, ["prefixed-lines"] = prefixed_lines, ["starts-with"] = starts_with, ["ends-with"] = ends_with, ["first-and-last-chars"] = first_and_last_chars, ["strip-ansi-escape-sequences"] = strip_ansi_escape_sequences, chars = chars, ["upper-first"] = upper_first}
