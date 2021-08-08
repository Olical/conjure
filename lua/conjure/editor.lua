local _2afile_2a = "fnl/conjure/editor.fnl"
local _1_
do
  local name_4_auto = "conjure.editor"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", fs = "conjure.fs", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local fs = _local_4_[2]
local nvim = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.editor"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local percent_fn
do
  local v_23_auto
  local function percent_fn0(total_fn)
    local function _8_(pc)
      return math.floor(((total_fn() / 100) * (pc * 100)))
    end
    return _8_
  end
  v_23_auto = percent_fn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["percent-fn"] = v_23_auto
  percent_fn = v_23_auto
end
local width
do
  local v_23_auto
  do
    local v_25_auto
    local function width0()
      return nvim.o.columns
    end
    v_25_auto = width0
    _1_["width"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["width"] = v_23_auto
  width = v_23_auto
end
local height
do
  local v_23_auto
  do
    local v_25_auto
    local function height0()
      return nvim.o.lines
    end
    v_25_auto = height0
    _1_["height"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["height"] = v_23_auto
  height = v_23_auto
end
local percent_width
do
  local v_23_auto
  do
    local v_25_auto = percent_fn(width)
    do end (_1_)["percent-width"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["percent-width"] = v_23_auto
  percent_width = v_23_auto
end
local percent_height
do
  local v_23_auto
  do
    local v_25_auto = percent_fn(height)
    do end (_1_)["percent-height"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["percent-height"] = v_23_auto
  percent_height = v_23_auto
end
local cursor_left
do
  local v_23_auto
  do
    local v_25_auto
    local function cursor_left0()
      return nvim.fn.screencol()
    end
    v_25_auto = cursor_left0
    _1_["cursor-left"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cursor-left"] = v_23_auto
  cursor_left = v_23_auto
end
local cursor_top
do
  local v_23_auto
  do
    local v_25_auto
    local function cursor_top0()
      return nvim.fn.screenrow()
    end
    v_25_auto = cursor_top0
    _1_["cursor-top"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cursor-top"] = v_23_auto
  cursor_top = v_23_auto
end
local go_to
do
  local v_23_auto
  do
    local v_25_auto
    local function go_to0(path_or_win, line, column)
      if a["string?"](path_or_win) then
        nvim.ex.edit(fs["localise-path"](path_or_win))
      end
      local _10_
      if ("number" == type(path_or_win)) then
        _10_ = path_or_win
      else
        _10_ = 0
      end
      return nvim.win_set_cursor(_10_, {line, a.dec(column)})
    end
    v_25_auto = go_to0
    _1_["go-to"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["go-to"] = v_23_auto
  go_to = v_23_auto
end
local go_to_mark
do
  local v_23_auto
  do
    local v_25_auto
    local function go_to_mark0(m)
      return nvim.ex.normal_(("`" .. m))
    end
    v_25_auto = go_to_mark0
    _1_["go-to-mark"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["go-to-mark"] = v_23_auto
  go_to_mark = v_23_auto
end
local go_back
do
  local v_23_auto
  do
    local v_25_auto
    local function go_back0()
      return nvim.ex.normal_(nvim.replace_termcodes("<c-o>", true, false, true))
    end
    v_25_auto = go_back0
    _1_["go-back"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["go-back"] = v_23_auto
  go_back = v_23_auto
end
local has_filetype_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function has_filetype_3f0(ft)
      local function _12_(_241)
        return (ft == _241)
      end
      return a.some(_12_, nvim.fn.getcompletion(ft, "filetype"))
    end
    v_25_auto = has_filetype_3f0
    _1_["has-filetype?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["has-filetype?"] = v_23_auto
  has_filetype_3f = v_23_auto
end
return nil