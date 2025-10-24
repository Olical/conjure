-- [nfnl] fnl/nfnl/string.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local M = define("conjure.nfnl.string")
M.join = function(...)
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
      local tmp_6_
      if ("string" == type(x)) then
        tmp_6_ = x
      elseif (nil == x) then
        tmp_6_ = x
      else
        tmp_6_ = core["pr-str"](x)
      end
      if (tmp_6_ ~= nil) then
        table.insert(result, tmp_6_)
      else
      end
    end
  else
  end
  return table.concat(result, sep)
end
M.split = function(s, pat)
  local acc = {}
  local done_3f = false
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
M["blank?"] = function(s)
  return (core["empty?"](s) or not string.find(s, "[^%s]"))
end
M.triml = function(s)
  return string.gsub(s, "^%s*(.-)", "%1")
end
M.trimr = function(s)
  return string.gsub(s, "(.-)%s*$", "%1")
end
M.trim = function(s)
  return string.gsub(s, "^%s*(.-)%s*$", "%1")
end
M["ends-with?"] = function(s, suffix)
  local suffix_len = #suffix
  local s_len = #s
  if (s_len >= suffix_len) then
    return (suffix == string.sub(s, (s_len - suffix_len - -1)))
  else
    return false
  end
end
return M
