-- [nfnl] Compiled from fnl/conjure/remote/transport/netrepl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local bit = autoload("bit")
local str = autoload("conjure.aniseed.string")
local function encode(msg)
  local n = a.count(msg)
  return (string.char(bit.band(n, 255), bit.band(bit.rshift(n, 8), 255), bit.band(bit.rshift(n, 16), 255), bit.band(bit.rshift(n, 24), 255)) .. msg)
end
local function split(chunk)
  local b0, b1, b2, b3 = string.byte(chunk, 1, 4)
  return bit.bor(bit.band(b0, 255), bit.lshift(bit.band(b1, 255), 8), bit.lshift(bit.band(b2, 255), 16), bit.lshift(bit.band(b3, 255), 24)), string.sub(chunk, 5)
end
local function decoder()
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
return {encode = encode, decoder = decoder}
