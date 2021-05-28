local _2afile_2a = "fnl/aniseed/string.fnl"
local _0_
do
  local name_0_ = "conjure.aniseed.string"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.aniseed.string"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local join
do
  local v_0_
  do
    local v_0_0
    local function join0(...)
      local args = {...}
      local function _3_(...)
        if (2 == a.count(args)) then
          return args
        else
          return {"", a.first(args)}
        end
      end
      local _let_0_ = _3_(...)
      local sep = _let_0_[1]
      local xs = _let_0_[2]
      local len = a.count(xs)
      local result = {}
      if (len > 0) then
        for i = 1, len do
          local x = xs[i]
          local _4_
          if ("string" == type(x)) then
            _4_ = x
          elseif (nil == x) then
            _4_ = x
          else
            _4_ = a["pr-str"](x)
          end
          if _4_ then
            table.insert(result, _4_)
          else
          end
        end
      end
      return table.concat(result, sep)
    end
    v_0_0 = join0
    _0_["join"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["join"] = v_0_
  join = v_0_
end
local split
do
  local v_0_
  do
    local v_0_0
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
    _0_["split"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["split"] = v_0_
  split = v_0_
end
local blank_3f
do
  local v_0_
  do
    local v_0_0
    local function blank_3f0(s)
      return (a["empty?"](s) or not string.find(s, "[^%s]"))
    end
    v_0_0 = blank_3f0
    _0_["blank?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["blank?"] = v_0_
  blank_3f = v_0_
end
local triml
do
  local v_0_
  do
    local v_0_0
    local function triml0(s)
      return string.gsub(s, "^%s*(.-)", "%1")
    end
    v_0_0 = triml0
    _0_["triml"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["triml"] = v_0_
  triml = v_0_
end
local trimr
do
  local v_0_
  do
    local v_0_0
    local function trimr0(s)
      return string.gsub(s, "(.-)%s*$", "%1")
    end
    v_0_0 = trimr0
    _0_["trimr"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["trimr"] = v_0_
  trimr = v_0_
end
local trim
do
  local v_0_
  do
    local v_0_0
    local function trim0(s)
      return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end
    v_0_0 = trim0
    _0_["trim"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["trim"] = v_0_
  trim = v_0_
end
return nil
