local _2afile_2a = "fnl/conjure/editor.fnl"
local _2amodule_name_2a = "conjure.editor"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, fs, nvim, util = autoload("conjure.aniseed.core"), autoload("conjure.fs"), autoload("conjure.aniseed.nvim"), autoload("conjure.util")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["util"] = util
local function percent_fn(total_fn)
  local function _1_(pc)
    return math.floor(((total_fn() / 100) * (pc * 100)))
  end
  return _1_
end
_2amodule_locals_2a["percent-fn"] = percent_fn
local function width()
  return nvim.o.columns
end
_2amodule_2a["width"] = width
local function height()
  return nvim.o.lines
end
_2amodule_2a["height"] = height
local percent_width = percent_fn(width)
do end (_2amodule_2a)["percent-width"] = percent_width
local percent_height = percent_fn(height)
do end (_2amodule_2a)["percent-height"] = percent_height
local function cursor_left()
  return nvim.fn.screencol()
end
_2amodule_2a["cursor-left"] = cursor_left
local function cursor_top()
  return nvim.fn.screenrow()
end
_2amodule_2a["cursor-top"] = cursor_top
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
local function go_to_mark(m)
  return nvim.ex.normal_(("`" .. m))
end
_2amodule_2a["go-to-mark"] = go_to_mark
local function go_back()
  return nvim.ex.normal_(util["replace-termcodes"]("<c-o>"))
end
_2amodule_2a["go-back"] = go_back
local function has_filetype_3f(ft)
  local function _5_(_241)
    return (ft == _241)
  end
  return a.some(_5_, nvim.fn.getcompletion(ft, "filetype"))
end
_2amodule_2a["has-filetype?"] = has_filetype_3f
return _2amodule_2a