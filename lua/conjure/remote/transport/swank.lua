local _2afile_2a = "fnl/conjure/remote/transport/swank.fnl"
local _2amodule_name_2a = "conjure.remote.transport.swank"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, log = autoload("conjure.aniseed.core"), autoload("conjure.log")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["log"] = log
local function encode(msg)
  local n = a.count(msg)
  local header = string.format("%06x", (1 + n))
  return (header .. msg .. "\n")
end
_2amodule_2a["encode"] = encode
local function decode(msg)
  local len = tonumber(string.sub(msg, 1, 7), 16)
  local cmd = string.sub(msg, 7, len)
  return cmd
end
_2amodule_2a["decode"] = decode
return _2amodule_2a