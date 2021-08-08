local _2afile_2a = "fnl/aniseed/string.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.string"
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
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.string"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local join
do
  local v_23_auto
  do
    local v_25_auto
    local function join0(...)
      local args = {...}
      local function _9_(...)
        if (2 == a.count(args)) then
          return args
        else
          return {"", a.first(args)}
        end
      end
      local _let_8_ = _9_(...)
      local sep = _let_8_[1]
      local xs = _let_8_[2]
      local len = a.count(xs)
      local result = {}
      if (len > 0) then
        for i = 1, len do
          local x = xs[i]
          local _10_
          if ("string" == type(x)) then
            _10_ = x
          elseif (nil == x) then
            _10_ = x
          else
            _10_ = a["pr-str"](x)
          end
          if _10_ then
            table.insert(result, _10_)
          else
          end
        end
      end
      return table.concat(result, sep)
    end
    v_25_auto = join0
    _1_["join"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["join"] = v_23_auto
  join = v_23_auto
end
local split
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = split0
    _1_["split"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["split"] = v_23_auto
  split = v_23_auto
end
local blank_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function blank_3f0(s)
      return (a["empty?"](s) or not string.find(s, "[^%s]"))
    end
    v_25_auto = blank_3f0
    _1_["blank?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["blank?"] = v_23_auto
  blank_3f = v_23_auto
end
local triml
do
  local v_23_auto
  do
    local v_25_auto
    local function triml0(s)
      return string.gsub(s, "^%s*(.-)", "%1")
    end
    v_25_auto = triml0
    _1_["triml"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["triml"] = v_23_auto
  triml = v_23_auto
end
local trimr
do
  local v_23_auto
  do
    local v_25_auto
    local function trimr0(s)
      return string.gsub(s, "(.-)%s*$", "%1")
    end
    v_25_auto = trimr0
    _1_["trimr"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["trimr"] = v_23_auto
  trimr = v_23_auto
end
local trim
do
  local v_23_auto
  do
    local v_25_auto
    local function trim0(s)
      return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end
    v_25_auto = trim0
    _1_["trim"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["trim"] = v_23_auto
  trim = v_23_auto
end
return nil
