-- [nfnl] Compiled from fnl/conjure/remote/transport/swank.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.remote.transport.swank"
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
local a, log = autoload("conjure.aniseed.core"), autoload("conjure.log")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["log"] = log
do local _ = {nil, nil, nil, nil, nil, nil, nil} end
local function encode(msg)
  local n = a.count(msg)
  local header = string.format("%06x", (1 + n))
  return (header .. msg .. "\n")
end
_2amodule_2a["encode"] = encode
do local _ = {encode, nil} end
local function decode(msg)
  local len = tonumber(string.sub(msg, 1, 7), 16)
  local cmd = string.sub(msg, 7, len)
  return cmd
end
_2amodule_2a["decode"] = decode
do local _ = {decode, nil} end
return _2amodule_2a
