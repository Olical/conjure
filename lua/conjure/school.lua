local _2afile_2a = "fnl/conjure/school.fnl"
local _1_
do
  local name_4_auto = "conjure.school"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", buffer = "conjure.buffer", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local buffer = _local_4_[2]
local config = _local_4_[3]
local editor = _local_4_[4]
local nvim = _local_4_[5]
local str = _local_4_[6]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.school"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local buf_name
do
  local v_23_auto = "conjure-school.fnl"
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-name"] = v_23_auto
  buf_name = v_23_auto
end
local upsert_buf
do
  local v_23_auto
  local function upsert_buf0()
    return buffer["upsert-hidden"](buf_name)
  end
  v_23_auto = upsert_buf0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["upsert-buf"] = v_23_auto
  upsert_buf = v_23_auto
end
local append
do
  local v_23_auto
  local function append0(lines)
    local buf = upsert_buf()
    local _8_
    if buffer["empty?"](buf) then
      _8_ = 0
    else
      _8_ = -1
    end
    return nvim.buf_set_lines(buf, _8_, -1, false, lines)
  end
  v_23_auto = append0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["append"] = v_23_auto
  append = v_23_auto
end
local map_str
do
  local v_23_auto
  local function map_str0(m)
    return (config["get-in"]({"mapping", "prefix"}) .. config["get-in"]({"mapping", m}))
  end
  v_23_auto = map_str0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["map-str"] = v_23_auto
  map_str = v_23_auto
end
local progress
do
  local v_23_auto
  local function progress0(n)
    return ("Lesson [" .. n .. "/7] complete!")
  end
  v_23_auto = progress0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["progress"] = v_23_auto
  progress = v_23_auto
end
local start
do
  local v_23_auto
  do
    local v_25_auto
    local function start0()
      if not editor["has-filetype?"]("fennel") then
        nvim.echo("Warning: No Fennel filetype found, falling back to Clojure syntax.", "Install https://github.com/Olical/aniseed for better Fennel support.")
        nvim.g["conjure#filetype#clojure"] = nvim.g["conjure#filetype#fennel"]
        nvim.ex.augroup("conjure_school_filetype")
        nvim.ex.autocmd_()
        nvim.ex.autocmd("BufNewFile,BufRead *.fnl setlocal filetype=clojure")
        nvim.ex.augroup("END")
      end
      local buf = upsert_buf()
      nvim.ex.edit(buf_name)
      nvim.buf_set_lines(buf, 0, -1, false, {})
      local _11_
      if ("<localleader>" == config["get-in"]({"mapping", "prefix"})) then
        if a["empty?"](nvim.g.maplocalleader) then
          nvim.g.maplocalleader = ","
          nvim.ex.edit()
          _11_ = {";; Your <localleader> wasn't configured so I've defaulted it to comma (,) for now.", ";; See :help localleader for more information. (let maplocalleader=\",\")"}
        else
          _11_ = {(";; Your <localleader> is currently mapped to \"" .. nvim.g.maplocalleader .. "\"")}
        end
      else
      _11_ = nil
      end
      return append(a.concat({"(module user.conjure-school", "  {require {school conjure.school}})", "", ";; Welcome to Conjure school!", ";; Grab yourself a nice beverage and let's get evaluating. I hope you enjoy!", "", ";; This language is Fennel, it's quite similar to Clojure.", ";; Conjure is written in Fennel, it's compiled to Lua and executed inside Neovim itself.", ";; This means we can work with a Lisp without installing or running anything else.", "", ";; Note: Some colorschemes will make the HUD unreadable, see here for more: https://git.io/JJ1Hl", "", ";; Let's learn how to evaluate it using Conjure's assortment of mappings.", ";; You can learn how to change these mappings with :help conjure-mappings", "", (";; Let's begin by evaluating the whole buffer using " .. map_str("eval_buf"))}, _11_, {"(school.lesson-1)"}))
    end
    v_25_auto = start0
    _1_["start"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["start"] = v_23_auto
  start = v_23_auto
end
local lesson_1
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_10()
      append({"", ";; Good job!", ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation.", ";; All results are appended to a log buffer. If that log is not open, the HUD will appear.", ";; The HUD closes automatically when you move your cursor.", "", ";; You can open the log buffer in a few ways:", (";;  * Horizontally - " .. map_str("log_split")), (";;  * Vertically - " .. map_str("log_vsplit")), (";;  * New tab - " .. map_str("log_tab")), "", (";; All visible log windows (including the HUD) can be closed with " .. map_str("log_close_visible")), ";; Try opening and closing the log window to get the hang of those key mappings.", ";; It's a regular window and buffer, so you can edit and close it however you want.", ";; Feel free to leave the log open in a split for the next lesson to see how it behaves.", "", ";; If you ever need to clear your log you can use the reset mappings:", (";; * Soft reset (leaves windows open) - " .. map_str("log_reset_soft")), (";; * Hard reset (closes windows, deletes the buffer) - " .. map_str("log_reset_hard")), "", ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment.", (";; Place your cursor on the inner form (the one inside the comment) and use " .. map_str("eval_current_form") .. " to evaluate it."), "(comment", "  (school.lesson-2))"})
      return progress(1)
    end
    v_25_auto = lesson_10
    _1_["lesson-1"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-1"] = v_23_auto
  lesson_1 = v_23_auto
end
local lesson_2
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_20()
      append({"", ";; Awesome! You evaluated the inner form under your cursor.", (";; If we want to evaluate the outermost form under our cursor, we can use " .. map_str("eval_root_form") .. " instead."), ";; Try that below to print some output and advance to the next lesson.", ";; You can place your cursor anywhere inside the (do ...) form or it's children.", "(do", "  (print \"Hello, World!\")", "  (school.lesson-3))"})
      return progress(2)
    end
    v_25_auto = lesson_20
    _1_["lesson-2"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-2"] = v_23_auto
  lesson_2 = v_23_auto
end
local lesson_3
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_30()
      append({"", ";; You evaluated the outermost form! Nice!", ";; Notice that the print output was captured and displayed in the log too.", ";; The result of every evaluation is stored in a Neovim register as well as the log.", (";; Try pressing \"" .. config["get-in"]({"eval", "result_register"}) .. "p to paste the contents of the register into your buffer."), (";; We can also evaluate a form and replace it with the result of the evaluation with " .. map_str("eval_replace_form")), (";; We'll try that in the next lesson, place your cursor inside the form below and press " .. map_str("eval_replace_form")), "(school.lesson-4)"})
      return progress(3)
    end
    v_25_auto = lesson_30
    _1_["lesson-3"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-3"] = v_23_auto
  lesson_3 = v_23_auto
end
local lesson_4
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_40()
      append({"", ";; Well done! Notice how the resulting string in the log also replaced the form in the buffer!", ";; Next let's try evaluating a form at a mark.", ";; Place your cursor on the next lesson form below and use mf to set the f mark at that location.", (";; Now move your cursor elsewhere in the buffer and use " .. map_str("eval_marked_form") .. "f to evaluate it."), ";; If you use a capital letter like mF you can even open a different file and evaluate that marked form without changing buffers!", "(school.lesson-5)"})
      return progress(4)
    end
    v_25_auto = lesson_40
    _1_["lesson-4"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-4"] = v_23_auto
  lesson_4 = v_23_auto
end
local lesson_5_message
do
  local v_23_auto
  do
    local v_25_auto = "This is the contents of school.lesson-5-message!"
    _1_["lesson-5-message"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-5-message"] = v_23_auto
  lesson_5_message = v_23_auto
end
local lesson_5
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_50()
      append({"", ";; Excellent!", ";; This is extremely useful when you want to evaluate a specific form repeatedly as you change code elsewhere in the file or project.", (";; Try inspecting the contents of the variable below by placing your cursor on it and pressing " .. map_str("eval_word")), "school.lesson-5-message", "", ";; You should see the contents in the HUD or log.", "", (";; You can evaluate visual selections with " .. map_str("eval_visual")), ";; Try evaluating the form below using a visual selection.", "(school.lesson-6)"})
      return progress(5)
    end
    v_25_auto = lesson_50
    _1_["lesson-5"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-5"] = v_23_auto
  lesson_5 = v_23_auto
end
local lesson_6_message
do
  local v_23_auto
  do
    local v_25_auto = "This is the contents of school.lesson-6-message!"
    _1_["lesson-6-message"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-6-message"] = v_23_auto
  lesson_6_message = v_23_auto
end
local lesson_6
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_60()
      append({"", ";; Wonderful!", ";; Visual evaluation is great for specific sections of a form.", (";; You can also evaluate a given motion with " .. map_str("eval_motion")), (";; Try " .. map_str("eval_motion") .. "iw below to evaluate the word."), "school.lesson-6-message", "", (";; Use " .. map_str("eval_motion") .. "a( to evaluate the lesson form."), "(school.lesson-7)"})
      return progress(6)
    end
    v_25_auto = lesson_60
    _1_["lesson-6"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-6"] = v_23_auto
  lesson_6 = v_23_auto
end
local lesson_7
do
  local v_23_auto
  do
    local v_25_auto
    local function lesson_70()
      append({"", ";; Excellent job, you made it to the end!", ";; To learn more about configuring Conjure, install the plugin and check out :help conjure", ";; You can learn about specific languages with :help conjure-client- and then tab completion.", ";; For example, conjure-client-fennel-aniseed or conjure-client-clojure-nrepl.", "", ";; I hope you have a wonderful time in Conjure!"})
      return progress(7)
    end
    v_25_auto = lesson_70
    _1_["lesson-7"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["lesson-7"] = v_23_auto
  lesson_7 = v_23_auto
end
return nil