local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.remote.transport.netrepl"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("bit"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local bit = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.transport.netrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local encode
do
  local v_0_
  local function encode0(msg)
    local n = a.count(msg)
    return (string.char(bit.band(n, 255), bit.band(bit.rshift(n, 8), 255), bit.band(bit.rshift(n, 16), 255), bit.band(bit.rshift(n, 24), 255)) .. msg)
  end
  v_0_ = encode0
  _0_0["encode"] = v_0_
  encode = v_0_
end
local function split(chunk)
  local b0, b1, b2, b3 = string.byte(chunk, 1, 4)
  return bit.bor(bit.band(b0, 255), bit.lshift(bit.band(b1, 255), 8), bit.lshift(bit.band(b2, 255), 16), bit.lshift(bit.band(b3, 255), 24)), string.sub(chunk, 5)
end
local decoder
do
  local v_0_
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
  v_0_ = decoder0
  _0_0["decoder"] = v_0_
  decoder = v_0_
end
return nil