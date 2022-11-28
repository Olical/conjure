local _2afile_2a = "fnl/conjure/remote/stdio2.fnl"
local _2amodule_name_2a = "conjure.remote.stdio2"
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
local a, client, log, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local uv = vim.loop
_2amodule_locals_2a["uv"] = uv
local function parse_cmd(x)
  if a["table?"](x) then
    return {cmd = a.first(x), args = a.rest(x)}
  elseif a["string?"](x) then
    return parse_cmd(str.split(x, "%s"))
  else
    return nil
  end
end
_2amodule_2a["parse-cmd"] = parse_cmd
return _2amodule_2a