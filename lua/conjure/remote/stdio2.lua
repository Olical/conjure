-- [nfnl] Compiled from fnl/conjure/remote/stdio2.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.remote.stdio2"
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
local a, client, log, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local uv = vim.loop
_2amodule_locals_2a["uv"] = uv
do local _ = {nil, nil} end
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
do local _ = {parse_cmd, nil} end
return _2amodule_2a
