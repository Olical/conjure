-- [nfnl] fnl/conjure/main.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local mapping = autoload("conjure.mapping")
local config = autoload("conjure.config")
local function main()
  return mapping.init(config.filetypes())
end
return {main = main}
