-- [nfnl] Compiled from fnl/conjure/remote/transport/bencode/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local impl = autoload("conjure.remote.transport.bencode.impl")
local a = autoload("conjure.aniseed.core")
local function new()
  return {data = ""}
end
local function decode_all(bs, part)
  local progress = 1
  local end_3f = false
  local s = (bs.data .. part)
  local acc = {}
  while ((progress < a.count(s)) and not end_3f) do
    local msg, consumed = impl.decode(s, progress)
    if a["nil?"](msg) then
      end_3f = true
    else
      table.insert(acc, msg)
      progress = consumed
    end
  end
  a.assoc(bs, "data", string.sub(s, progress))
  return acc
end
local function encode(...)
  return impl.encode(...)
end
return {new = new, ["decode-all"] = decode_all, encode = encode}
