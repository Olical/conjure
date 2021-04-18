local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.string"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core")}
local a = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.string"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local join
do
  local v_0_
  local function join0(...)
    local args = {...}
    local function _1_(...)
      if (2 == a.count(args)) then
        return args
      else
        return {"", a.first(args)}
      end
    end
    local _let_0_ = _1_(...)
    local sep = _let_0_[1]
    local xs = _let_0_[2]
    local len = a.count(xs)
    local result = {}
    if (len > 0) then
      for i = 1, len do
        local x = xs[i]
        local _2_0
        if ("string" == type(x)) then
          _2_0 = x
        elseif (nil == x) then
          _2_0 = x
        else
          _2_0 = a["pr-str"](x)
        end
        if _2_0 then
          table.insert(result, _2_0)
        else
        end
      end
    end
    return table.concat(result, sep)
  end
  v_0_ = join0
  _0_0["join"] = v_0_
  join = v_0_
end
local split
do
  local v_0_
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
  v_0_ = split0
  _0_0["split"] = v_0_
  split = v_0_
end
local blank_3f
do
  local v_0_
  local function blank_3f0(s)
    return (a["empty?"](s) or not string.find(s, "[^%s]"))
  end
  v_0_ = blank_3f0
  _0_0["blank?"] = v_0_
  blank_3f = v_0_
end
local triml
do
  local v_0_
  local function triml0(s)
    return string.gsub(s, "^%s*(.-)", "%1")
  end
  v_0_ = triml0
  _0_0["triml"] = v_0_
  triml = v_0_
end
local trimr
do
  local v_0_
  local function trimr0(s)
    return string.gsub(s, "(.-)%s*$", "%1")
  end
  v_0_ = trimr0
  _0_0["trimr"] = v_0_
  trimr = v_0_
end
local trim
do
  local v_0_
  local function trim0(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
  end
  v_0_ = trim0
  _0_0["trim"] = v_0_
  trim = v_0_
end
return nil
