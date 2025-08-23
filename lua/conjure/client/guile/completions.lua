-- [nfnl] fnl/conjure/client/guile/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local keywords = autoload("conjure.client.scheme.keywords")
local util = autoload("conjure.util")
local tsc = autoload("conjure.tree-sitter-completions")
local res = autoload("conjure.resources")
local M = define("conjure.client.guile.completions")
M["guile-repl-completion-code"] = res["get-resource-contents"]("client/guile/completion.scm")
M["build-completion-request"] = function(prefix)
  return ("(%conjure:get-guile-completions " .. a["pr-str"](prefix) .. ")")
end
local function parse_guile_completion_result(rs)
  local tbl_21_ = {}
  local i_22_ = 0
  for token in string.gmatch(rs, "\"([^\"^%s]+)\"") do
    local val_23_ = token
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
M["format-results"] = function(rs)
  local cmpls = parse_guile_completion_result(rs)
  local last = table.remove(cmpls)
  table.insert(cmpls, 1, last)
  return cmpls
end
M["get-static-completions"] = function(prefix)
  local keyword_set = keywords["get-set"]("guile")
  local ts_completions = tsc["get-completions-at-cursor"]("scheme", "scheme")
  local prefix_filter = tsc["make-prefix-filter"](prefix)
  return prefix_filter(util["ordered-distinct"](a.concat(ts_completions, keyword_set)))
end
return M
