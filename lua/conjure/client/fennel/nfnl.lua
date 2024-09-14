-- [nfnl] Compiled from fnl/conjure/client/fennel/nfnl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local ts = autoload("conjure.tree-sitter")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local log = autoload("conjure.log")
local core = autoload("nfnl.core")
local fennel = autoload("nfnl.fennel")
local str = autoload("nfnl.string")
local repl = autoload("nfnl.repl")
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
local function eval_str(opts)
  local eval = repl.new()
  local results = eval(opts.code)
  local result_strs = core.map(fennel.view, results)
  local lines = text["split-lines"](str.join("\n", result_strs))
  return log.append(lines)
end
--[[ (+ 10 20) ]]
return {["comment-node?"] = comment_node_3f, ["form-node?"] = form_node_3f, ["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["eval-str"] = eval_str}
