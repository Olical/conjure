-- [nfnl] fnl/nfnl/init.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_.define
local autoload = _local_1_.autoload
local notify = autoload("conjure.nfnl.notify")
local vim = _G.vim
local M = define("nfnl")
if vim then
  notify.warn("require(\"nfnl\") is deprecated. nfnl now activates via ftplugin. You can remove require(\"nfnl\") from your config.")
else
end
M.setup = function(opts)
  notify.warn("conjure.nfnl.setup() is deprecated. Set vim.g.nfnl#compile_on_write directly instead.")
  if opts then
    vim.g["nfnl#compile_on_write"] = opts.compile_on_write
    return nil
  else
    return nil
  end
end
return M
