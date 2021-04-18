local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.school"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local buffer = _local_0_[2]
local config = _local_0_[3]
local editor = _local_0_[4]
local nvim = _local_0_[5]
local str = _local_0_[6]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.school"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_name = "conjure-school.fnl"
local function upsert_buf()
  return buffer["upsert-hidden"](buf_name)
end
local function append(lines)
  local buf = upsert_buf()
  local _1_
  if buffer["empty?"](buf) then
    _1_ = 0
  else
    _1_ = -1
  end
  return nvim.buf_set_lines(buf, _1_, -1, false, lines)
end
local function map_str(m)
  return (config["get-in"]({"mapping", "prefix"}) .. config["get-in"]({"mapping", m}))
end
local function progress(n)
  return ("Lesson [" .. n .. "/7] complete!")
end
local start
do
  local v_0_
  local function start0()
    if not editor["has-filetype?"]("fennel") then
      nvim.echo("Warning: No Fennel filetype found, falling back to Clojure syntax.", "Install https://github.com/Olical/fennel.vim for better Fennel support.")
      nvim.g["conjure#filetype#clojure"] = nvim.g["conjure#filetype#fennel"]
      nvim.ex.augroup("conjure_school_filetype")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("BufNewFile,BufRead *.fnl setlocal filetype=clojure")
      nvim.ex.augroup("END")
    end
    local buf = upsert_buf()
    nvim.ex.edit(buf_name)
    nvim.buf_set_lines(buf, 0, -1, false, {})
    local _2_
    if ("<localleader>" == config["get-in"]({"mapping", "prefix"})) then
      if a["empty?"](nvim.g.maplocalleader) then
        nvim.g.maplocalleader = ","
        nvim.ex.edit()
        _2_ = {";; Your <localleader> wasn't configured so I've defaulted it to comma (,) for now.", ";; See :help localleader for more information. (let maplocalleader=\",\")"}
      else
        _2_ = {(";; Your <localleader> is currently mapped to \"" .. nvim.g.maplocalleader .. "\"")}
      end
    else
    _2_ = nil
    end
    return append(a.concat({"(module user.conjure-school", "  {require {school conjure.school}})", "", ";; Welcome to Conjure school!", ";; Grab yourself a nice beverage and let's get evaluating. I hope you enjoy!", "", ";; This language is Fennel, it's quite similar to Clojure.", ";; Conjure is written in Fennel, it's compiled to Lua and executed inside Neovim itself.", ";; This means we can work with a Lisp without installing or running anything else.", "", ";; Note: Some colorschemes will make the HUD unreadable, see here for more: https://git.io/JJ1Hl", "", ";; Let's learn how to evaluate it using Conjure's assortment of mappings.", ";; You can learn how to change these mappings with :help conjure-mappings", "", (";; Let's begin by evaluating the whole buffer using " .. map_str("eval_buf"))}, _2_, {"(school.lesson-1)"}))
  end
  v_0_ = start0
  _0_0["start"] = v_0_
  start = v_0_
end
local lesson_1
do
  local v_0_
  local function lesson_10()
    append({"", ";; Good job!", ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation.", ";; All results are appended to a log buffer. If that log is not open, the HUD will appear.", ";; The HUD closes automatically when you move your cursor.", "", ";; You can open the log buffer in a few ways:", (";;  * Horizontally - " .. map_str("log_split")), (";;  * Vertically - " .. map_str("log_vsplit")), (";;  * New tab - " .. map_str("log_tab")), "", (";; All visible log windows (including the HUD) can be closed with " .. map_str("log_close_visible")), ";; Try opening and closing the log window to get the hang of those key mappings.", ";; It's a regular window and buffer, so you can edit and close it however you want.", ";; Feel free to leave the log open in a split for the next lesson to see how it behaves.", "", ";; If you ever need to clear your log you can use the reset mappings:", (";; * Soft reset (leaves windows open) - " .. map_str("log_reset_soft")), (";; * Hard reset (closes windows, deletes the buffer) - " .. map_str("log_reset_hard")), "", ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment.", (";; Place your cursor on the inner form (the one inside the comment) and use " .. map_str("eval_current_form") .. " to evaluate it."), "(comment", "  (school.lesson-2))"})
    return progress(1)
  end
  v_0_ = lesson_10
  _0_0["lesson-1"] = v_0_
  lesson_1 = v_0_
end
local lesson_2
do
  local v_0_
  local function lesson_20()
    append({"", ";; Awesome! You evaluated the inner form under your cursor.", (";; If we want to evaluate the outermost form under our cursor, we can use " .. map_str("eval_root_form") .. " instead."), ";; Try that below to print some output and advance to the next lesson.", ";; You can place your cursor anywhere inside the (do ...) form or it's children.", "(do", "  (print \"Hello, World!\")", "  (school.lesson-3))"})
    return progress(2)
  end
  v_0_ = lesson_20
  _0_0["lesson-2"] = v_0_
  lesson_2 = v_0_
end
local lesson_3
do
  local v_0_
  local function lesson_30()
    append({"", ";; You evaluated the outermost form! Nice!", ";; Notice that the print output was captured and displayed in the log too.", ";; The result of every evaluation is stored in a Neovim register as well as the log.", (";; Try pressing \"" .. config["get-in"]({"eval", "result_register"}) .. "p to paste the contents of the register into your buffer."), (";; We can also evaluate a form and replace it with the result of the evaluation with " .. map_str("eval_replace_form")), (";; We'll try that in the next lesson, place your cursor inside the form below and press " .. map_str("eval_replace_form")), "(school.lesson-4)"})
    return progress(3)
  end
  v_0_ = lesson_30
  _0_0["lesson-3"] = v_0_
  lesson_3 = v_0_
end
local lesson_4
do
  local v_0_
  local function lesson_40()
    append({"", ";; Well done! Notice how the resulting string in the log also replaced the form in the buffer!", ";; Next let's try evaluating a form at a mark.", ";; Place your cursor on the next lesson form below and use mf to set the f mark at that location.", (";; Now move your cursor elsewhere in the buffer and use " .. map_str("eval_marked_form") .. "f to evaluate it."), ";; If you use a capital letter like mF you can even open a different file and evaluate that marked form without changing buffers!", "(school.lesson-5)"})
    return progress(4)
  end
  v_0_ = lesson_40
  _0_0["lesson-4"] = v_0_
  lesson_4 = v_0_
end
local lesson_5_message
do
  local v_0_ = "This is the contents of school.lesson-5-message!"
  _0_0["lesson-5-message"] = v_0_
  lesson_5_message = v_0_
end
local lesson_5
do
  local v_0_
  local function lesson_50()
    append({"", ";; Excellent!", ";; This is extremely useful when you want to evaluate a specific form repeatedly as you change code elsewhere in the file or project.", (";; Try inspecting the contents of the variable below by placing your cursor on it and pressing " .. map_str("eval_word")), "school.lesson-5-message", "", ";; You should see the contents in the HUD or log.", "", (";; You can evaluate visual selections with " .. map_str("eval_visual")), ";; Try evaluating the form below using a visual selection.", "(school.lesson-6)"})
    return progress(5)
  end
  v_0_ = lesson_50
  _0_0["lesson-5"] = v_0_
  lesson_5 = v_0_
end
local lesson_6_message
do
  local v_0_ = "This is the contents of school.lesson-6-message!"
  _0_0["lesson-6-message"] = v_0_
  lesson_6_message = v_0_
end
local lesson_6
do
  local v_0_
  local function lesson_60()
    append({"", ";; Wonderful!", ";; Visual evaluation is great for specific sections of a form.", (";; You can also evaluate a given motion with " .. map_str("eval_motion")), (";; Try " .. map_str("eval_motion") .. "iw below to evaluate the word."), "school.lesson-6-message", "", (";; Use " .. map_str("eval_motion") .. "a( to evaluate the lesson form."), "(school.lesson-7)"})
    return progress(6)
  end
  v_0_ = lesson_60
  _0_0["lesson-6"] = v_0_
  lesson_6 = v_0_
end
local lesson_7
do
  local v_0_
  local function lesson_70()
    append({"", ";; Excellent job, you made it to the end!", ";; To learn more about configuring Conjure, install the plugin and check out :help conjure", ";; You can learn about specific languages with :help conjure-client- and then tab completion.", ";; For example, conjure-client-fennel-aniseed or conjure-client-clojure-nrepl.", "", ";; I hope you have a wonderful time in Conjure!"})
    return progress(7)
  end
  v_0_ = lesson_70
  _0_0["lesson-7"] = v_0_
  lesson_7 = v_0_
end
return nil