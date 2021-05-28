local _2afile_2a = "fnl/conjure/remote/transport/netrepl.fnl"
local _0_
do
  local name_0_ = "conjure.remote.transport.netrepl"
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
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("bit"), autoload("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", bit = "bit", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local bit = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.remote.transport.netrepl"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local encode
do
  local v_0_
  do
    local v_0_0
    local function encode0(msg)
      local n = a.count(msg)
      return (string.char(bit.band(n, 255), bit.band(bit.rshift(n, 8), 255), bit.band(bit.rshift(n, 16), 255), bit.band(bit.rshift(n, 24), 255)) .. msg)
    end
    v_0_0 = encode0
    _0_["encode"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["encode"] = v_0_
  encode = v_0_
end
local split
do
  local v_0_
  local function split0(chunk)
    local b0, b1, b2, b3 = string.byte(chunk, 1, 4)
    return bit.bor(bit.band(b0, 255), bit.lshift(bit.band(b1, 255), 8), bit.lshift(bit.band(b2, 255), 16), bit.lshift(bit.band(b3, 255), 24)), string.sub(chunk, 5)
  end
  v_0_ = split0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["split"] = v_0_
  split = v_0_
end
local decoder
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = decoder0
    _0_["decoder"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["decoder"] = v_0_
  decoder = v_0_
end
return nil