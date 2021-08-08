local _2afile_2a = "fnl/conjure/remote/transport/netrepl.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.transport.netrepl"
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
    return {autoload("conjure.aniseed.core"), autoload("bit"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", bit = "bit", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local bit = _local_4_[2]
local str = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.transport.netrepl"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local encode
do
  local v_23_auto
  do
    local v_25_auto
    local function encode0(msg)
      local n = a.count(msg)
      return (string.char(bit.band(n, 255), bit.band(bit.rshift(n, 8), 255), bit.band(bit.rshift(n, 16), 255), bit.band(bit.rshift(n, 24), 255)) .. msg)
    end
    v_25_auto = encode0
    _1_["encode"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["encode"] = v_23_auto
  encode = v_23_auto
end
local split
do
  local v_23_auto
  local function split0(chunk)
    local b0, b1, b2, b3 = string.byte(chunk, 1, 4)
    return bit.bor(bit.band(b0, 255), bit.lshift(bit.band(b1, 255), 8), bit.lshift(bit.band(b2, 255), 16), bit.lshift(bit.band(b3, 255), 24)), string.sub(chunk, 5)
  end
  v_23_auto = split0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["split"] = v_23_auto
  split = v_23_auto
end
local decoder
do
  local v_23_auto
  do
    local v_25_auto
    local function decoder0()
      local awaiting = nil
      local buffer = ""
      local function reset()
        awaiting = nil
        buffer = ""
        return nil
      end
      local function decode(chunk, acc)
        local acc0 = (acc or {})
        if awaiting then
          local before = a.count(buffer)
          local seen = a.count(chunk)
          buffer = (buffer .. chunk)
          if (seen > awaiting) then
            local consumed = string.sub(buffer, 1, (before + awaiting))
            local next_chunk = string.sub(chunk, a.inc(awaiting))
            table.insert(acc0, consumed)
            reset()
            return decode(next_chunk, acc0)
          elseif (seen == awaiting) then
            table.insert(acc0, buffer)
            reset()
            return acc0
          else
            awaiting = (awaiting - seen)
            return acc0
          end
        else
          local n, rem = split(chunk)
          awaiting = n
          return decode(rem, acc0)
        end
      end
      return decode
    end
    v_25_auto = decoder0
    _1_["decoder"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["decoder"] = v_23_auto
  decoder = v_23_auto
end
return nil