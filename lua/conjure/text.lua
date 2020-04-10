local _0_0 = nil
do
  local name_23_0_ = "conjure.text"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local str = _2_[2]
do local _ = ({nil, _0_0, nil})[2] end
local trim = nil
do
  local v_23_0_ = nil
  local function trim0(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
  end
  v_23_0_ = trim0
  _0_0["aniseed/locals"]["trim"] = v_23_0_
  trim = v_23_0_
end
local left_sample = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function left_sample0(s, limit)
      local flat = trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
      if (limit >= a.count(flat)) then
        return flat
      else
        return (string.sub(flat, 0, a.dec(limit)) .. "...")
      end
    end
    v_23_0_0 = left_sample0
    _0_0["left-sample"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["left-sample"] = v_23_0_
  left_sample = v_23_0_
end
local right_sample = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function right_sample0(s, limit)
      return string.reverse(left_sample(string.reverse(s), limit))
    end
    v_23_0_0 = right_sample0
    _0_0["right-sample"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["right-sample"] = v_23_0_
  right_sample = v_23_0_
end
local split_lines = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function split_lines0(s)
      return str.split(s, "[^\n]+")
    end
    v_23_0_0 = split_lines0
    _0_0["split-lines"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["split-lines"] = v_23_0_
  split_lines = v_23_0_
end
local prefixed_lines = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function prefixed_lines0(s, prefix)
      local function _3_(line)
        return (prefix .. line)
      end
      return a.map(_3_, split_lines(s))
    end
    v_23_0_0 = prefixed_lines0
    _0_0["prefixed-lines"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["prefixed-lines"] = v_23_0_
  prefixed_lines = v_23_0_
end
local starts_with = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function starts_with0(str0, start)
      return (string.sub(str0, 1, a.count(start)) == start)
    end
    v_23_0_0 = starts_with0
    _0_0["starts-with"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["starts-with"] = v_23_0_
  starts_with = v_23_0_
end
return nil