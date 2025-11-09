-- [nfnl] .nvim.fnl
local _local_1_ = require("nfnl.module")
local autoload = _local_1_.autoload
local reload = autoload("plenary.reload")
local notify = autoload("nfnl.notify")
vim.g["conjure#client#scheme#stdio#command"] = "chicken-csi -:c"
vim.g["conjure#client#scheme#stdio#prompt_pattern"] = "\n-#;%d-> "
vim.g["conjure#client#scheme#stdio#value_prefix_pattern"] = false
package.path = (package.path .. ";test/lua/?.lua")
return nil
