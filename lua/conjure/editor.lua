-- [nfnl] fnl/conjure/editor.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local fs = autoload("conjure.fs")
local util = autoload("conjure.util")
local M = define("conjure.editor")
local function percent_fn(total_fn)
  local function _2_(pc)
    return math.floor(((total_fn() / 100) * (pc * 100)))
  end
  return _2_
end
M.width = function()
  return vim.o.columns
end
M.height = function()
  return vim.o.lines
end
M["percent-width"] = percent_fn(M.width)
M["percent-height"] = percent_fn(M.height)
M["cursor-left"] = function()
  return vim.fn.screencol()
end
M["cursor-top"] = function()
  return vim.fn.screenrow()
end
M["go-to"] = function(path_or_win, line, column)
  if core["string?"](path_or_win) then
    vim.cmd.edit(fs["localise-path"](path_or_win))
  else
  end
  local _4_
  if ("number" == type(path_or_win)) then
    _4_ = path_or_win
  else
    _4_ = 0
  end
  return vim.api.nvim_win_set_cursor(_4_, {line, core.dec(column)})
end
M["go-to-mark"] = function(m)
  return vim.cmd(("normal! `" .. m))
end
M["go-back"] = function()
  return vim.cmd(("normal! " .. util["replace-termcodes"]("<c-o>")))
end
M["has-filetype?"] = function(ft)
  local function _6_(_241)
    return (ft == _241)
  end
  return core.some(_6_, vim.fn.getcompletion(ft, "filetype"))
end
return M
