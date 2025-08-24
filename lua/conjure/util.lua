-- [nfnl] fnl/conjure/util.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("nfnl.core")
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
M["ordered-distinct"] = function(l)
  local seen = {}
  local result = {}
  for _, v in ipairs(l) do
    if not a.get(seen, v) then
      a.assoc(seen, v, true)
      table.insert(result, v)
    else
    end
  end
  return result
end
return M
