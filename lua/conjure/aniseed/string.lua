local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.string"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
  return {require("conjure.aniseed.core")}
end
local _1_ = _2_(...)
local a = _1_[1]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local join = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function join0(...)
      local args = {...}
      local function _4_(...)
        if (2 == a.count(args)) then
          return args
        else
          return {"", a.first(args)}
        end
      end
      local _3_ = _4_(...)
      local sep = _3_[1]
      local xs = _3_[2]
      local len = a.count(xs)
      local result = {}
      if (len > 0) then
        for i = 1, len do
          local x = xs[i]
          local _5_0 = nil
          if ("string" == type(x)) then
            _5_0 = x
          elseif (nil == x) then
            _5_0 = x
          else
            _5_0 = a["pr-str"](x)
          end
          if _5_0 then
            table.insert(result, _5_0)
          else
          end
        end
      end
      return table.concat(result, sep)
    end
    v_0_0 = join0
    _0_0["join"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["join"] = v_0_
  join = v_0_
end
local split = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function split0(s, pat)
      local done_3f = false
      local acc = {}
      local index = 1
      while not done_3f do
        local start, _end = string.find(s, pat, index)
        if ("nil" == type(start)) then
          table.insert(acc, string.sub(s, index))
          done_3f = true
        else
          table.insert(acc, string.sub(s, index, (start - 1)))
          index = (_end + 1)
        end
      end
      return acc
    end
    v_0_0 = split0
    _0_0["split"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["split"] = v_0_
  split = v_0_
end
local blank_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function blank_3f0(s)
      return (a["empty?"](s) or not string.find(s, "[^%s]"))
    end
    v_0_0 = blank_3f0
    _0_0["blank?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["blank?"] = v_0_
  blank_3f = v_0_
end
local triml = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function triml0(s)
      return string.gsub(s, "^%s*(.-)", "%1")
    end
    v_0_0 = triml0
    _0_0["triml"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["triml"] = v_0_
  triml = v_0_
end
local trimr = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function trimr0(s)
      return string.gsub(s, "(.-)%s*$", "%1")
    end
    v_0_0 = trimr0
    _0_0["trimr"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["trimr"] = v_0_
  trimr = v_0_
end
local trim = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function trim0(s)
      return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end
    v_0_0 = trim0
    _0_0["trim"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["trim"] = v_0_
  trim = v_0_
end
return nil
