-- [nfnl] Compiled from fnl/conjure/editor.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local fs = autoload("conjure.fs")
local nvim = autoload("conjure.aniseed.nvim")
local util = autoload("conjure.util")
local function percent_fn(total_fn)
  local function _2_(pc)
    return math.floor(((total_fn() / 100) * (pc * 100)))
  end
  return _2_
end
local function width()
  return vim.o.columns
end
local function height()
  return vim.o.lines
end
local percent_width = percent_fn(width)
local percent_height = percent_fn(height)
local function cursor_left()
  return vim.fn.screencol()
end
local function cursor_top()
  return vim.fn.screenrow()
end
local function go_to(path_or_win, line, column)
  if a["string?"](path_or_win) then
    nvim.ex.edit(fs["localise-path"](path_or_win))
  else
  end
  local _4_
  if ("number" == type(path_or_win)) then
    _4_ = path_or_win
  else
    _4_ = 0
  end
  return nvim.win_set_cursor(_4_, {line, a.dec(column)})
end
local function go_to_mark(m)
  return nvim.ex.normal_(("`" .. m))
end
local function go_back()
  return nvim.ex.normal_(util["replace-termcodes"]("<c-o>"))
end
local function has_filetype_3f(ft)
  local function _6_(_241)
    return (ft == _241)
  end
  return a.some(_6_, nvim.fn.getcompletion(ft, "filetype"))
end
return {width = width, height = height, ["percent-width"] = percent_width, ["percent-height"] = percent_height, ["cursor-left"] = cursor_left, ["cursor-top"] = cursor_top, ["go-to"] = go_to, ["go-to-mark"] = go_to_mark, ["go-back"] = go_back, ["has-filetype?"] = has_filetype_3f}
