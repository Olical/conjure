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
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.string"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local join = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function join0(...)
      local args = {...}
      local function _2_(...)
        if (2 == a.count(args)) then
          return args
        else
          return {"", a.first(args)}
        end
      end
      local _let_0_ = _2_(...)
      local sep = _let_0_[1]
      local xs = _let_0_[2]
      local len = a.count(xs)
      local result = {}
      if (len > 0) then
        for i = 1, len do
          local x = xs[i]
          local _3_0 = nil
          if ("string" == type(x)) then
            _3_0 = x
          elseif (nil == x) then
            _3_0 = x
          else
            _3_0 = a["pr-str"](x)
          end
          if _3_0 then
            table.insert(result, _3_0)
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
