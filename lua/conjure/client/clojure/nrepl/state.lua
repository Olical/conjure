-- [nfnl] fnl/conjure/client/clojure/nrepl/state.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local client = autoload("conjure.client")
local M = define("conjure.client.clojure.nrepl.state")
local function _2_()
  return {conn = nil, ["auto-repl-port"] = nil, ["auto-repl-proc"] = nil, ["join-next"] = {key = nil}}
end
M.get = client["new-state"](_2_)
return M
