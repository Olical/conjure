local _2afile_2a = "fnl/conjure/editor.fnl"
local _0_
do
  local name_0_ = "conjure.editor"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", fs = "conjure.fs", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local fs = _local_0_[2]
local nvim = _local_0_[3]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.editor"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local percent_fn
do
  local v_0_
  local function percent_fn0(total_fn)
    local function _3_(pc)
      return math.floor(((total_fn() / 100) * (pc * 100)))
    end
    return _3_
  end
  v_0_ = percent_fn0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["percent-fn"] = v_0_
  percent_fn = v_0_
end
local width
do
  local v_0_
  do
    local v_0_0
    local function width0()
      return nvim.o.columns
    end
    v_0_0 = width0
    _0_["width"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["width"] = v_0_
  width = v_0_
end
local height
do
  local v_0_
  do
    local v_0_0
    local function height0()
      return nvim.o.lines
    end
    v_0_0 = height0
    _0_["height"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["height"] = v_0_
  height = v_0_
end
local percent_width
do
  local v_0_
  do
    local v_0_0 = percent_fn(width)
    do end (_0_)["percent-width"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["percent-width"] = v_0_
  percent_width = v_0_
end
local percent_height
do
  local v_0_
  do
    local v_0_0 = percent_fn(height)
    do end (_0_)["percent-height"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["percent-height"] = v_0_
  percent_height = v_0_
end
local cursor_left
do
  local v_0_
  do
    local v_0_0
    local function cursor_left0()
      return nvim.fn.screencol()
    end
    v_0_0 = cursor_left0
    _0_["cursor-left"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cursor-left"] = v_0_
  cursor_left = v_0_
end
local cursor_top
do
  local v_0_
  do
    local v_0_0
    local function cursor_top0()
      return nvim.fn.screenrow()
    end
    v_0_0 = cursor_top0
    _0_["cursor-top"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cursor-top"] = v_0_
  cursor_top = v_0_
end
local go_to
do
  local v_0_
  do
    local v_0_0
    local function go_to0(path_or_win, line, column)
      if a["string?"](path_or_win) then
        nvim.ex.edit(fs["localise-path"](path_or_win))
      end
      local _4_
      if ("number" == type(path_or_win)) then
        _4_ = path_or_win
      else
        _4_ = 0
      end
      return nvim.win_set_cursor(_4_, {line, a.dec(column)})
    end
    v_0_0 = go_to0
    _0_["go-to"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["go-to"] = v_0_
  go_to = v_0_
end
local go_to_mark
do
  local v_0_
  do
    local v_0_0
    local function go_to_mark0(m)
      return nvim.ex.normal_(("`" .. m))
    end
    v_0_0 = go_to_mark0
    _0_["go-to-mark"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["go-to-mark"] = v_0_
  go_to_mark = v_0_
end
local go_back
do
  local v_0_
  do
    local v_0_0
    local function go_back0()
      return nvim.ex.normal_(nvim.replace_termcodes("<c-o>", true, false, true))
    end
    v_0_0 = go_back0
    _0_["go-back"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["go-back"] = v_0_
  go_back = v_0_
end
local has_filetype_3f
do
  local v_0_
  do
    local v_0_0
    local function has_filetype_3f0(ft)
      local function _3_(_241)
        return (ft == _241)
      end
      return a.some(_3_, nvim.fn.getcompletion(ft, "filetype"))
    end
    v_0_0 = has_filetype_3f0
    _0_["has-filetype?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["has-filetype?"] = v_0_
  has_filetype_3f = v_0_
end
return nil