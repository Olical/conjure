-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local tsc = autoload("conjure.tree-sitter-completions")
local util = autoload("conjure.util")
local M = define("conjure.client.common-lisp.completions")
M["get-static-completions"] = function(prefix)
  local prefix_filter = util["make-prefix-filter"](prefix)
  return prefix_filter(tsc["get-completions-at-cursor"]("commonlisp", "common-lisp"))
end
return M
