-- [nfnl] fnl/conjure/client/javascript/repl.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local config = autoload("conjure.config")
local M = define("conjure.client.javascript.repl")
local function filetype()
  return vim.bo.filetype
end
M.type = function()
  if ("javascript" == filetype()) then
    return "js"
  elseif ("typescript" == filetype()) then
    return "ts"
  else
    return nil
  end
end
local function get_repl_cmd()
  if ("js" == M.type()) then
    return "node -i"
  elseif ("ts" == M.type()) then
    return "ts-node -i"
  else
    return nil
  end
end
M["update-repl-cmd"] = function()
  return config.merge({client = {javascript = {stdio = {command = get_repl_cmd()}}}}, {["overwrite?"] = true})
end
return M
