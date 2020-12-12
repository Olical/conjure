local _0_0 = nil
do
  local name_0_ = "conjure.text"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local str = _1_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.text"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local trailing_newline_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function trailing_newline_3f0(s)
      return ("\n" == string.sub(s, -1))
    end
    v_0_0 = trailing_newline_3f0
    _0_0["trailing-newline?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["trailing-newline?"] = v_0_
  trailing_newline_3f = v_0_
end
local trim_last_newline = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function trim_last_newline0(s)
      if trailing_newline_3f(s) then
        return string.sub(s, 1, -2)
      else
        return s
      end
    end
    v_0_0 = trim_last_newline0
    _0_0["trim-last-newline"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["trim-last-newline"] = v_0_
  trim_last_newline = v_0_
end
local left_sample = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function left_sample0(s, limit)
      local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
      if (limit >= a.count(flat)) then
        return flat
      else
        return (string.sub(flat, 0, a.dec(limit)) .. "...")
      end
    end
    v_0_0 = left_sample0
    _0_0["left-sample"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["left-sample"] = v_0_
  left_sample = v_0_
end
local right_sample = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function right_sample0(s, limit)
      return string.reverse(left_sample(string.reverse(s), limit))
    end
    v_0_0 = right_sample0
    _0_0["right-sample"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["right-sample"] = v_0_
  right_sample = v_0_
end
local split_lines = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function split_lines0(s)
      return str.split(s, "\n")
    end
    v_0_0 = split_lines0
    _0_0["split-lines"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["split-lines"] = v_0_
  split_lines = v_0_
end
local prefixed_lines = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function prefixed_lines0(s, prefix, opts)
      local function _3_(_4_0)
        local _5_ = _4_0
        local n = _5_[1]
        local line = _5_[2]
        if ((1 == n) and a.get(opts, "skip-first?")) then
          return line
        else
          return (prefix .. line)
        end
      end
      return a["map-indexed"](_3_, split_lines(s))
    end
    v_0_0 = prefixed_lines0
    _0_0["prefixed-lines"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["prefixed-lines"] = v_0_
  prefixed_lines = v_0_
end
local starts_with = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function starts_with0(str0, start)
      return (string.sub(str0, 1, a.count(start)) == start)
    end
    v_0_0 = starts_with0
    _0_0["starts-with"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["starts-with"] = v_0_
  starts_with = v_0_
end
local ends_with = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function ends_with0(str0, _end)
      return ((_end == "") or (_end == string.sub(str0, ( - a.count(_end)))))
    end
    v_0_0 = ends_with0
    _0_0["ends-with"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["ends-with"] = v_0_
  ends_with = v_0_
end
local strip_ansi_escape_sequences = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function strip_ansi_escape_sequences0(s)
      return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
    end
    v_0_0 = strip_ansi_escape_sequences0
    _0_0["strip-ansi-escape-sequences"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["strip-ansi-escape-sequences"] = v_0_
  strip_ansi_escape_sequences = v_0_
end
local chars = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function chars0(s)
      local res = {}
      if s then
        for c in string.gmatch(s, ".") do
          table.insert(res, c)
        end
      end
      return res
    end
    v_0_0 = chars0
    _0_0["chars"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["chars"] = v_0_
  chars = v_0_
end
local upper_first = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function upper_first0(s)
      if s then
        return s:gsub("^%l", string.upper)
      end
    end
    v_0_0 = upper_first0
    _0_0["upper-first"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["upper-first"] = v_0_
  upper_first = v_0_
end
return nil