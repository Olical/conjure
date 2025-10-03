-- [nfnl] fnl/conjure/main.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local mapping = autoload("conjure.mapping")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local M = define("conjure.main")
M.main = function()
  mapping.init(config.filetypes())
  return log["setup-auto-flush"]()
end
return M
