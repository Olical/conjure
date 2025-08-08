-- [nfnl] fnl/conjure/util.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local M = define("conjure.util")
M["wrap-require-fn-call"] = function(mod, f)
  local function _2_()
    return require(mod)[f]()
  end
  return _2_
end
M["replace-termcodes"] = function(s)
  return vim.api.nvim_replace_termcodes(s, true, false, true)
end
M["concat-nodup"] = function(l, r)
  local seen = {}
  local result = {}
  for _, v in ipairs(l) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    else
    end
  end
  for _, v in ipairs(r) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    else
    end
  end
  return result
end
M.dedup = function(l)
  return M["concat-nodup"]({}, l)
end
M["make-prefix-filter"] = function(prefix)
  local sanitized_prefix = string.gsub((prefix or ""), "%%", "%%%%")
  local prefix_pattern = ("^" .. sanitized_prefix)
  local prefix_filter
  local function _5_(s)
    return string.match(s, prefix_pattern)
  end
  prefix_filter = _5_
  local function _6_(list)
    return a.filter(prefix_filter, list)
  end
  return _6_
end
return M
