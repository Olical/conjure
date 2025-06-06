-- [nfnl] fnl/conjure/school.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local buffer = autoload("conjure.buffer")
local config = autoload("conjure.config")
local editor = autoload("conjure.editor")
local nvim = autoload("conjure.aniseed.nvim")
local str = autoload("conjure.nfnl.string")
local buf_name = "conjure-school.fnl"
local function upsert_buf()
  return buffer["upsert-hidden"](buf_name)
end
local function append(lines)
  local buf = upsert_buf()
  local current_buf_str = str.join("\n", vim.api.nvim_buf_get_lines(0, 0, -1, true))
  local to_insert_str = str.join("\n", lines)
  if not string.find(current_buf_str, to_insert_str, 0, true) then
    local _2_
    if buffer["empty?"](buf) then
      _2_ = 0
    else
      _2_ = -1
    end
    vim.api.nvim_buf_set_lines(buf, _2_, -1, false, lines)
    return true
  else
    return nil
  end
end
local function map_str(m)
  return (config["get-in"]({"mapping", "prefix"}) .. config["get-in"]({"mapping", m}))
end
local function progress(n)
  return ("Lesson [" .. n .. "/7] complete!")
end
local function append_or_warn(current_progress, lines)
  if append(lines) then
    return progress(current_progress)
  else
    return "You've already completed this lesson! You can (u)ndo and run it again though if you'd like."
  end
end
local function start()
  if not editor["has-filetype?"]("fennel") then
    vim.notify_once("Warning: No Fennel filetype found, falling back to Clojure syntax.", "Install https://github.com/atweiden/vim-fennel for better Fennel support.")
    vim.g["conjure#filetype#clojure"] = vim.g["conjure#filetype#fennel"]
    nvim.ex.augroup("conjure_school_filetype")
    nvim.ex.autocmd_()
    nvim.ex.autocmd("BufNewFile,BufRead *.fnl setlocal filetype=clojure")
    nvim.ex.augroup("END")
  else
  end
  local maplocalleader_was_unset_3f
  if (("<localleader>" == config["get-in"]({"mapping", "prefix"})) and core["empty?"](vim.g.maplocalleader)) then
    vim.g.maplocalleader = ","
    maplocalleader_was_unset_3f = true
  else
    maplocalleader_was_unset_3f = nil
  end
  local buf = upsert_buf()
  nvim.ex.edit(buf_name)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  local _8_
  if maplocalleader_was_unset_3f then
    _8_ = {";; Your <localleader> wasn't configured so I've defaulted it to comma (,) for now.", ";; See :help localleader for more information. (let maplocalleader=\",\")"}
  else
    _8_ = {(";; Your <localleader> is currently mapped to \"" .. vim.g.maplocalleader .. "\"")}
  end
  return append(core.concat({"(local school (require :conjure.school))", "", ";; Welcome to Conjure school!", ";; Grab yourself a nice beverage and let's get evaluating. I hope you enjoy!", "", ";; This language is Fennel, it's quite similar to Clojure.", ";; Conjure is written in Fennel, it's compiled to Lua and executed inside Neovim itself.", ";; This means we can work with a Lisp without installing or running anything else.", "", ";; Note: Some colorschemes will make the HUD unreadable, see here for more: https://git.io/JJ1Hl", "", ";; Let's learn how to evaluate it using Conjure's assortment of mappings.", ";; You can learn how to change these mappings with :help conjure-mappings", "", (";; Let's begin by evaluating the whole buffer using " .. map_str("eval_buf"))}, _8_, {"(school.lesson-1)"}))
end
local function lesson_1()
  return append_or_warn(1, {"", ";; Good job!", ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation.", ";; All results are appended to a log buffer. If that log is not open, the HUD will appear.", ";; The HUD closes automatically when you move your cursor.", "", ";; You can open the log buffer in a few ways:", (";;  * Horizontally - " .. map_str("log_split")), (";;  * Vertically - " .. map_str("log_vsplit")), (";;  * New tab - " .. map_str("log_tab")), "", (";; All visible log windows (including the HUD) can be closed with " .. map_str("log_close_visible")), ";; Try opening and closing the log window to get the hang of those key mappings.", ";; It's a regular window and buffer, so you can edit and close it however you want.", ";; Feel free to leave the log open in a split for the next lesson to see how it behaves.", "", ";; If you ever need to clear your log you can use the reset mappings:", (";; * Soft reset (leaves windows open) - " .. map_str("log_reset_soft")), (";; * Hard reset (closes windows, deletes the buffer) - " .. map_str("log_reset_hard")), "", ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment.", (";; Place your cursor on the inner form (the one inside the comment) and use " .. map_str("eval_current_form") .. " to evaluate it."), "(comment", "  (school.lesson-2))"})
end
local function lesson_2()
  return append_or_warn(2, {"", ";; Awesome! You evaluated the inner form under your cursor.", (";; If we want to evaluate the outermost form under our cursor, we can use " .. map_str("eval_root_form") .. " instead."), ";; Try that below to print some output and advance to the next lesson.", ";; You can place your cursor anywhere inside the (do ...) form or it's children.", "(do", "  (print \"Hello, World!\")", "  (school.lesson-3))"})
end
local function lesson_3()
  return append_or_warn(3, {"", ";; You evaluated the outermost form! Nice!", ";; Notice that the print output was captured and displayed in the log too.", ";; The result of every evaluation is stored in a Neovim register as well as the log.", (";; Try pressing \"" .. config["get-in"]({"eval", "result_register"}) .. "p to paste the contents of the register into your buffer."), (";; We can also evaluate a form and replace it with the result of the evaluation with " .. map_str("eval_replace_form")), (";; We'll try that in the next lesson, place your cursor inside the form below and press " .. map_str("eval_replace_form")), "(school.lesson-4)"})
end
local function lesson_4()
  return append_or_warn(4, {"", ";; Well done! Notice how the resulting string in the log also replaced the form in the buffer!", ";; Next let's try evaluating a form at a mark.", ";; Place your cursor on the next lesson form below and use mf to set the f mark at that location.", (";; Now move your cursor elsewhere in the buffer and use " .. map_str("eval_marked_form") .. "f to evaluate it."), ";; If you use a capital letter like mF you can even open a different file and evaluate that marked form without changing buffers!", "(school.lesson-5)"})
end
local lesson_5_message = "This is the contents of school.lesson-5-message!"
local function lesson_5()
  return append_or_warn(5, {"", ";; Excellent!", ";; This is extremely useful when you want to evaluate a specific form repeatedly as you change code elsewhere in the file or project.", (";; Try inspecting the contents of the variable below by placing your cursor on it and pressing " .. map_str("eval_word")), "school.lesson-5-message", "", ";; You should see the contents in the HUD or log.", "", (";; You can evaluate visual selections with " .. map_str("eval_visual")), ";; Try evaluating the form below using a visual selection.", "(school.lesson-6)"})
end
local lesson_6_message = "This is the contents of school.lesson-6-message!"
local function lesson_6()
  return append_or_warn(6, {"", ";; Wonderful!", ";; Visual evaluation is great for specific sections of a form.", (";; You can also evaluate a given motion with " .. map_str("eval_motion")), (";; Try " .. map_str("eval_motion") .. "iw below to evaluate the word."), "school.lesson-6-message", "", (";; Use " .. map_str("eval_motion") .. "a( to evaluate the lesson form."), "(school.lesson-7)"})
end
local function lesson_7()
  return append_or_warn(7, {"", ";; Excellent job, you made it to the end!", ";; To learn more about configuring Conjure, install the plugin and check out :help conjure", ";; You can learn about specific languages with :help conjure-client- and then tab completion.", ";; For example, conjure-client-fennel-nfnl or conjure-client-clojure-nrepl.", "", ";; I hope you have a wonderful time in Conjure!"})
end
return {start = start, ["lesson-1"] = lesson_1, ["lesson-2"] = lesson_2, ["lesson-3"] = lesson_3, ["lesson-4"] = lesson_4, ["lesson-5"] = lesson_5, ["lesson-6"] = lesson_6, ["lesson-7"] = lesson_7, ["lesson-5-message"] = lesson_5_message, ["lesson-6-message"] = lesson_6_message}
