-- [nfnl] fnl/conjure/remote/stdio2.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local uv = vim.uv
local function parse_cmd(x)
  if core["table?"](x) then
    return {cmd = core.first(x), args = core.rest(x)}
  elseif core["string?"](x) then
    return parse_cmd(str.split(x, "%s"))
  else
    return nil
  end
end
return {["parse-cmd"] = parse_cmd}
