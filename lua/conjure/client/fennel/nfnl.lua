-- [nfnl] Compiled from fnl/conjure/client/fennel/nfnl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local ts = autoload("conjure.tree-sitter")
local config = autoload("conjure.config")
local comment_node_3f = ts["lisp-comment-node?"]
local function form_node_3f(node)
  return ts["node-surrounded-by-form-pair-chars?"](node, {{"#(", ")"}})
end
local buf_suffix = ".fnl"
local comment_prefix = "; "
config.merge({client = {fennel = {nfnl = {}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {nfnl = {mapping = {}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "nfnl"})
return {["comment-node?"] = comment_node_3f, ["form-node?"] = form_node_3f, ["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix}
