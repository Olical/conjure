-- [nfnl] Compiled from fnl/conjure/remote/stdio2.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local uv = vim.loop
local function parse_cmd(x)
  if a["table?"](x) then
    return {cmd = a.first(x), args = a.rest(x)}
  elseif a["string?"](x) then
    return parse_cmd(str.split(x, "%s"))
  else
    return nil
  end
end
return {["parse-cmd"] = parse_cmd}
