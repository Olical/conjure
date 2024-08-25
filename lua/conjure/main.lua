-- [nfnl] Compiled from fnl/conjure/main.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local mapping = autoload("conjure.mapping")
local config = autoload("conjure.config")
local function main()
  return mapping.init(config.filetypes())
end
return {main = main}
