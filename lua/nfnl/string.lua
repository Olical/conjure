-- [nfnl] Compiled from fnl/nfnl/string.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("nfnl.core")
local function join(...)
  local args = {...}
  local function _2_(...)
    if (2 == core.count(args)) then
      return args
    else
      return {"", core.first(args)}
    end
  end
  local _let_3_ = _2_(...)
  local sep = _let_3_[1]
  local xs = _let_3_[2]
  local len = core.count(xs)
  local result = {}
  if (len > 0) then
    for i = 1, len do
      local x = xs[i]
      local tmp_6_auto
      if ("string" == type(x)) then
        tmp_6_auto = x
      elseif (nil == x) then
        tmp_6_auto = x
      else
        tmp_6_auto = core["pr-str"](x)
      end
      if (tmp_6_auto ~= nil) then
        table.insert(result, tmp_6_auto)
      else
      end
    end
  else
  end
  return table.concat(result, sep)
end
local function split(s, pat)
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
local function blank_3f(s)
  return (core["empty?"](s) or not string.find(s, "[^%s]"))
end
local function triml(s)
  return string.gsub(s, "^%s*(.-)", "%1")
end
local function trimr(s)
  return string.gsub(s, "(.-)%s*$", "%1")
end
local function trim(s)
  return string.gsub(s, "^%s*(.-)%s*$", "%1")
end
local function ends_with_3f(s, suffix)
  local suffix_len = #suffix
  local s_len = #s
  if (s_len >= suffix_len) then
    return (suffix == string.sub(s, (s_len - suffix_len - -1)))
  else
    return false
  end
end
return {join = join, split = split, ["blank?"] = blank_3f, triml = triml, trimr = trimr, trim = trim, ["ends-with?"] = ends_with_3f}
