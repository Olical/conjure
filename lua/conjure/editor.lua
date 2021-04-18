local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.editor"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.fs"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local fs = _local_0_[2]
local nvim = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.editor"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local function percent_fn(total_fn)
  local function _1_(pc)
    return math.floor(((total_fn() / 100) * (pc * 100)))
  end
  return _1_
end
local width
do
  local v_0_
  local function width0()
    return nvim.o.columns
  end
  v_0_ = width0
  _0_0["width"] = v_0_
  width = v_0_
end
local height
do
  local v_0_
  local function height0()
    return nvim.o.lines
  end
  v_0_ = height0
  _0_0["height"] = v_0_
  height = v_0_
end
local percent_width
do
  local v_0_ = percent_fn(width)
  _0_0["percent-width"] = v_0_
  percent_width = v_0_
end
local percent_height
do
  local v_0_ = percent_fn(height)
  _0_0["percent-height"] = v_0_
  percent_height = v_0_
end
local cursor_left
do
  local v_0_
  local function cursor_left0()
    return nvim.fn.screencol()
  end
  v_0_ = cursor_left0
  _0_0["cursor-left"] = v_0_
  cursor_left = v_0_
end
local cursor_top
do
  local v_0_
  local function cursor_top0()
    return nvim.fn.screenrow()
  end
  v_0_ = cursor_top0
  _0_0["cursor-top"] = v_0_
  cursor_top = v_0_
end
local go_to
do
  local v_0_
  local function go_to0(path_or_win, line, column)
    if a["string?"](path_or_win) then
      nvim.ex.edit(fs["localise-path"](path_or_win))
    end
    local _2_
    if ("number" == type(path_or_win)) then
      _2_ = path_or_win
    else
      _2_ = 0
    end
    return nvim.win_set_cursor(_2_, {line, a.dec(column)})
  end
  v_0_ = go_to0
  _0_0["go-to"] = v_0_
  go_to = v_0_
end
local go_to_mark
do
  local v_0_
  local function go_to_mark0(m)
    return nvim.ex.normal_(("`" .. m))
  end
  v_0_ = go_to_mark0
  _0_0["go-to-mark"] = v_0_
  go_to_mark = v_0_
end
local go_back
do
  local v_0_
  local function go_back0()
    return nvim.ex.normal_(nvim.replace_termcodes("<c-o>", true, false, true))
  end
  v_0_ = go_back0
  _0_0["go-back"] = v_0_
  go_back = v_0_
end
local has_filetype_3f
do
  local v_0_
  local function has_filetype_3f0(ft)
    local function _1_(_241)
      return (ft == _241)
    end
    return a.some(_1_, nvim.fn.getcompletion(ft, "filetype"))
  end
  v_0_ = has_filetype_3f0
  _0_0["has-filetype?"] = v_0_
  has_filetype_3f = v_0_
end
return nil