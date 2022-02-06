local _2afile_2a = "fnl/aniseed/string.fnl"
local _2amodule_name_2a = "conjure.aniseed.string"
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
local autoload = (require("conjure.aniseed.autoload")).autoload
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
local function join(...)
  local args = {...}
  local function _2_(...)
    if (2 == a.count(args)) then
      return args
    else
      return {"", a.first(args)}
    end
  end
  local _let_1_ = _2_(...)
  local sep = _let_1_[1]
  local xs = _let_1_[2]
  local len = a.count(xs)
  local result = {}
  if (len > 0) then
    for i = 1, len do
      local x = xs[i]
      local _3_
      if ("string" == type(x)) then
        _3_ = x
      elseif (nil == x) then
        _3_ = x
      else
        _3_ = a["pr-str"](x)
      end
      if (_3_ ~= nil) then
        table.insert(result, _3_)
      else
      end
    end
  else
  end
  return table.concat(result, sep)
end
_2amodule_2a["join"] = join
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
_2amodule_2a["split"] = split
local function blank_3f(s)
  return (a["empty?"](s) or not string.find(s, "[^%s]"))
end
_2amodule_2a["blank?"] = blank_3f
local function triml(s)
  return string.gsub(s, "^%s*(.-)", "%1")
end
_2amodule_2a["triml"] = triml
local function trimr(s)
  return string.gsub(s, "(.-)%s*$", "%1")
end
_2amodule_2a["trimr"] = trimr
local function trim(s)
  return string.gsub(s, "^%s*(.-)%s*$", "%1")
end
_2amodule_2a["trim"] = trim
return _2amodule_2a
