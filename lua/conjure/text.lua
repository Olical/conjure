local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.text"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local str = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.text"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local trailing_newline_3f
do
  local v_0_
  local function trailing_newline_3f0(s)
    return ("\n" == string.sub(s, -1))
  end
  v_0_ = trailing_newline_3f0
  _0_0["trailing-newline?"] = v_0_
  trailing_newline_3f = v_0_
end
local trim_last_newline
do
  local v_0_
  local function trim_last_newline0(s)
    if trailing_newline_3f(s) then
      return string.sub(s, 1, -2)
    else
      return s
    end
  end
  v_0_ = trim_last_newline0
  _0_0["trim-last-newline"] = v_0_
  trim_last_newline = v_0_
end
local left_sample
do
  local v_0_
  local function left_sample0(s, limit)
    local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
    if (limit >= a.count(flat)) then
      return flat
    else
      return (string.sub(flat, 0, a.dec(limit)) .. "...")
    end
  end
  v_0_ = left_sample0
  _0_0["left-sample"] = v_0_
  left_sample = v_0_
end
local right_sample
do
  local v_0_
  local function right_sample0(s, limit)
    return string.reverse(left_sample(string.reverse(s), limit))
  end
  v_0_ = right_sample0
  _0_0["right-sample"] = v_0_
  right_sample = v_0_
end
local split_lines
do
  local v_0_
  local function split_lines0(s)
    return str.split(s, "\n")
  end
  v_0_ = split_lines0
  _0_0["split-lines"] = v_0_
  split_lines = v_0_
end
local prefixed_lines
do
  local v_0_
  local function prefixed_lines0(s, prefix, opts)
    local function _2_(_1_0)
      local _arg_0_ = _1_0
      local n = _arg_0_[1]
      local line = _arg_0_[2]
      if ((1 == n) and a.get(opts, "skip-first?")) then
        return line
      else
        return (prefix .. line)
      end
    end
    return a["map-indexed"](_2_, split_lines(s))
  end
  v_0_ = prefixed_lines0
  _0_0["prefixed-lines"] = v_0_
  prefixed_lines = v_0_
end
local starts_with
do
  local v_0_
  local function starts_with0(str0, start)
    return (string.sub(str0, 1, a.count(start)) == start)
  end
  v_0_ = starts_with0
  _0_0["starts-with"] = v_0_
  starts_with = v_0_
end
local ends_with
do
  local v_0_
  local function ends_with0(str0, _end)
    return ((_end == "") or (_end == string.sub(str0, ( - a.count(_end)))))
  end
  v_0_ = ends_with0
  _0_0["ends-with"] = v_0_
  ends_with = v_0_
end
local strip_ansi_escape_sequences
do
  local v_0_
  local function strip_ansi_escape_sequences0(s)
    return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
  end
  v_0_ = strip_ansi_escape_sequences0
  _0_0["strip-ansi-escape-sequences"] = v_0_
  strip_ansi_escape_sequences = v_0_
end
local chars
do
  local v_0_
  local function chars0(s)
    local res = {}
    if s then
      for c in string.gmatch(s, ".") do
        table.insert(res, c)
      end
    end
    return res
  end
  v_0_ = chars0
  _0_0["chars"] = v_0_
  chars = v_0_
end
local upper_first
do
  local v_0_
  local function upper_first0(s)
    if s then
      return s:gsub("^%l", string.upper)
    end
  end
  v_0_ = upper_first0
  _0_0["upper-first"] = v_0_
  upper_first = v_0_
end
return nil