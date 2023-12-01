-- [nfnl] Compiled from fnl/conjure/remote/transport/bencode/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.remote.transport.bencode"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, impl = autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.bencode.impl")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["impl"] = impl
do local _ = {nil, nil, nil, nil, nil, nil, nil} end
local function new()
  return {data = ""}
end
_2amodule_2a["new"] = new
do local _ = {new, nil} end
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
_2amodule_2a["decode-all"] = decode_all
do local _ = {decode_all, nil} end
local function encode(...)
  return impl.encode(...)
end
_2amodule_2a["encode"] = encode
do local _ = {encode, nil} end
return _2amodule_2a
