-- [nfnl] fnl/conjure/client/scheme/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = require("conjure.nfnl.core")
local keywords = autoload("conjure.client.scheme.keywords")
local config = autoload("conjure.config")
local util = autoload("conjure.util")
local tsc = autoload("conjure.tree-sitter-completions")
local M = define("conjure.client.scheme.completions")
local function get_lang_key_from_stdio_command(command)
  if string.match(command, "mit") then
    return "mit"
  elseif string.match(command, "petite") then
    return "chez"
  elseif string.match(command, "csi") then
    return "chicken"
  else
    return "common"
  end
end
M["get-completions"] = function(prefix)
  local stdio_command = config["get-in"]({"client", "scheme", "stdio", "command"})
  local lang_key = get_lang_key_from_stdio_command(stdio_command)
  local keyword_set = keywords["get-set"](lang_key)
  local ts_cmpl = tsc["get-completions-at-cursor"]("scheme", "scheme")
  local all_cmpl = a.concat(ts_cmpl, keyword_set)
  local distinct_cmpl = util["ordered-distinct"](all_cmpl)
  local prefix_filter = tsc["make-prefix-filter"](prefix)
  return prefix_filter(distinct_cmpl)
end
return M
