-- [nfnl] fnl/conjure/util.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local a = autoload("conjure.nfnl.core")
local vim = _G.vim
local M = define("conjure.util")
M.os = function()
  if ("\\" == string.sub(package.config, 1, 1)) then
    return "windows"
  else
    return "unix"
  end
end
M["wrap-require-fn-call"] = function(mod, f)
  local function _3_()
    return require(mod)[f]()
  end
  return _3_
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
