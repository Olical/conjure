local _2afile_2a = "fnl/conjure/text.fnl"
local _1_
do
  local name_4_auto = "conjure.text"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {require("conjure.aniseed.core"), require("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local str = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.text"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local trailing_newline_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function trailing_newline_3f0(s)
      return ("\n" == string.sub(s, -1))
    end
    v_25_auto = trailing_newline_3f0
    _1_["trailing-newline?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["trailing-newline?"] = v_23_auto
  trailing_newline_3f = v_23_auto
end
local trim_last_newline
do
  local v_23_auto
  do
    local v_25_auto
    local function trim_last_newline0(s)
      if trailing_newline_3f(s) then
        return string.sub(s, 1, -2)
      else
        return s
      end
    end
    v_25_auto = trim_last_newline0
    _1_["trim-last-newline"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["trim-last-newline"] = v_23_auto
  trim_last_newline = v_23_auto
end
local left_sample
do
  local v_23_auto
  do
    local v_25_auto
    local function left_sample0(s, limit)
      local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
      if (limit >= a.count(flat)) then
        return flat
      else
        return (string.sub(flat, 0, a.dec(limit)) .. "...")
      end
    end
    v_25_auto = left_sample0
    _1_["left-sample"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["left-sample"] = v_23_auto
  left_sample = v_23_auto
end
local right_sample
do
  local v_23_auto
  do
    local v_25_auto
    local function right_sample0(s, limit)
      return string.reverse(left_sample(string.reverse(s), limit))
    end
    v_25_auto = right_sample0
    _1_["right-sample"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["right-sample"] = v_23_auto
  right_sample = v_23_auto
end
local split_lines
do
  local v_23_auto
  do
    local v_25_auto
    local function split_lines0(s)
      return str.split(s, "\n")
    end
    v_25_auto = split_lines0
    _1_["split-lines"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["split-lines"] = v_23_auto
  split_lines = v_23_auto
end
local prefixed_lines
do
  local v_23_auto
  do
    local v_25_auto
    local function prefixed_lines0(s, prefix, opts)
      local function _12_(_10_)
        local _arg_11_ = _10_
        local n = _arg_11_[1]
        local line = _arg_11_[2]
        if ((1 == n) and a.get(opts, "skip-first?")) then
          return line
        else
          return (prefix .. line)
        end
      end
      return a["map-indexed"](_12_, split_lines(s))
    end
    v_25_auto = prefixed_lines0
    _1_["prefixed-lines"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prefixed-lines"] = v_23_auto
  prefixed_lines = v_23_auto
end
local starts_with
do
  local v_23_auto
  do
    local v_25_auto
    local function starts_with0(str0, start)
      return (string.sub(str0, 1, a.count(start)) == start)
    end
    v_25_auto = starts_with0
    _1_["starts-with"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["starts-with"] = v_23_auto
  starts_with = v_23_auto
end
local ends_with
do
  local v_23_auto
  do
    local v_25_auto
    local function ends_with0(str0, _end)
      return ((_end == "") or (_end == string.sub(str0, ( - a.count(_end)))))
    end
    v_25_auto = ends_with0
    _1_["ends-with"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ends-with"] = v_23_auto
  ends_with = v_23_auto
end
local strip_ansi_escape_sequences
do
  local v_23_auto
  do
    local v_25_auto
    local function strip_ansi_escape_sequences0(s)
      return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
    end
    v_25_auto = strip_ansi_escape_sequences0
    _1_["strip-ansi-escape-sequences"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["strip-ansi-escape-sequences"] = v_23_auto
  strip_ansi_escape_sequences = v_23_auto
end
local chars
do
  local v_23_auto
  do
    local v_25_auto
    local function chars0(s)
      local res = {}
      if s then
        for c in string.gmatch(s, ".") do
          table.insert(res, c)
        end
      end
      return res
    end
    v_25_auto = chars0
    _1_["chars"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["chars"] = v_23_auto
  chars = v_23_auto
end
local upper_first
do
  local v_23_auto
  do
    local v_25_auto
    local function upper_first0(s)
      if s then
        return s:gsub("^%l", string.upper)
      end
    end
    v_25_auto = upper_first0
    _1_["upper-first"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["upper-first"] = v_23_auto
  upper_first = v_23_auto
end
return nil