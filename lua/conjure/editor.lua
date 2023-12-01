-- [nfnl] Compiled from fnl/conjure/editor.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.editor"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, fs, nvim, util = autoload("conjure.aniseed.core"), autoload("conjure.fs"), autoload("conjure.aniseed.nvim"), autoload("conjure.util")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["util"] = util
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function percent_fn(total_fn)
  local function _1_(pc)
    return math.floor(((total_fn() / 100) * (pc * 100)))
  end
  return _1_
end
_2amodule_locals_2a["percent-fn"] = percent_fn
do local _ = {percent_fn, nil} end
local function width()
  return nvim.o.columns
end
_2amodule_2a["width"] = width
do local _ = {width, nil} end
local function height()
  return nvim.o.lines
end
_2amodule_2a["height"] = height
do local _ = {height, nil} end
local percent_width = percent_fn(width)
do end (_2amodule_2a)["percent-width"] = percent_width
do local _ = {nil, nil} end
local percent_height = percent_fn(height)
do end (_2amodule_2a)["percent-height"] = percent_height
do local _ = {nil, nil} end
local function cursor_left()
  return nvim.fn.screencol()
end
_2amodule_2a["cursor-left"] = cursor_left
do local _ = {cursor_left, nil} end
local function cursor_top()
  return nvim.fn.screenrow()
end
_2amodule_2a["cursor-top"] = cursor_top
do local _ = {cursor_top, nil} end
local function go_to(path_or_win, line, column)
  if a["string?"](path_or_win) then
    nvim.ex.edit(fs["localise-path"](path_or_win))
  else
  end
  local _3_
  if ("number" == type(path_or_win)) then
    _3_ = path_or_win
  else
    _3_ = 0
  end
  return nvim.win_set_cursor(_3_, {line, a.dec(column)})
end
_2amodule_2a["go-to"] = go_to
do local _ = {go_to, nil} end
local function go_to_mark(m)
  return nvim.ex.normal_(("`" .. m))
end
_2amodule_2a["go-to-mark"] = go_to_mark
do local _ = {go_to_mark, nil} end
local function go_back()
  return nvim.ex.normal_(util["replace-termcodes"]("<c-o>"))
end
_2amodule_2a["go-back"] = go_back
do local _ = {go_back, nil} end
local function has_filetype_3f(ft)
  local function _5_(_241)
    return (ft == _241)
  end
  return a.some(_5_, nvim.fn.getcompletion(ft, "filetype"))
end
_2amodule_2a["has-filetype?"] = has_filetype_3f
do local _ = {has_filetype_3f, nil} end
return _2amodule_2a
