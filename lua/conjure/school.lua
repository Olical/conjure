local _0_0 = nil
do
  local name_23_0_ = "conjure.school"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local a = _2_[1]
local buffer = _2_[2]
local config = _2_[3]
local editor = _2_[4]
local nvim = _2_[5]
do local _ = ({nil, _0_0, nil})[2] end
local buf_name = nil
do
  local v_23_0_ = "conjure-school.fnl"
  _0_0["aniseed/locals"]["buf-name"] = v_23_0_
  buf_name = v_23_0_
end
local upsert_buf = nil
do
  local v_23_0_ = nil
  local function upsert_buf0()
    return buffer["upsert-hidden"](buf_name)
  end
  v_23_0_ = upsert_buf0
  _0_0["aniseed/locals"]["upsert-buf"] = v_23_0_
  upsert_buf = v_23_0_
end
local append = nil
do
  local v_23_0_ = nil
  local function append0(lines)
    local buf = upsert_buf()
    local _3_
    if buffer["empty?"](buf) then
      _3_ = 0
    else
      _3_ = -1
    end
    return nvim.buf_set_lines(buf, _3_, -1, false, lines)
  end
  v_23_0_ = append0
  _0_0["aniseed/locals"]["append"] = v_23_0_
  append = v_23_0_
end
local map_str = nil
do
  local v_23_0_ = nil
  local function map_str0(m)
    return (config.mappings.prefix .. a["get-in"](config, {"mappings", m}))
  end
  v_23_0_ = map_str0
  _0_0["aniseed/locals"]["map-str"] = v_23_0_
  map_str = v_23_0_
end
local progress = nil
do
  local v_23_0_ = nil
  local function progress0(n)
    return ("Lesson [" .. n .. "/?] complete!")
  end
  v_23_0_ = progress0
  _0_0["aniseed/locals"]["progress"] = v_23_0_
  progress = v_23_0_
end
local start = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function start0()
      if not editor["has-filetype?"]("fennel") then
        a.println(("Warning: No Fennel filetype found, falling back to Clojure syntax.\n" .. "Install https://github.com/bakpakin/fennel.vim for better Fennel support.\n"))
        nvim.ex.augroup("conjure_school_filetype")
        nvim.ex.autocmd_()
        nvim.ex.autocmd("BufNewFile,BufRead *.fnl set filetype=fennel | set syntax=clojure")
        nvim.ex.augroup("END")
      end
      do
        local buf = upsert_buf()
        nvim.ex.edit(buf_name)
        nvim.buf_set_lines(buf, 0, -1, false, {})
        local _4_
        if ("<localleader>" == config.mappings.prefix) then
          _4_ = {(";; Your <localleader> is currently mapped to " .. nvim.g.maplocalleader)}
        else
        _4_ = nil
        end
        return append(a.concat({";; Warning: This is under active development and isn't finished.", "", "(module user.conjure-school", "  {require {school conjure.school}})", "", ";; Welcome to Conjure school, I hope you enjoy your time here!", ";; This language is Fennel, it's quite similar to Clojure.", ";; Let's learn how to evaluate it using Conjure's assortment of mappings.", ";; You can learn how to change these mappings with :help conjure-mappings", "", (";; Let's begin by evaluating the whole buffer using " .. map_str("eval-buf"))}, _4_, {"(school.lesson-1)"}))
      end
    end
    v_23_0_0 = start0
    _0_0["start"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["start"] = v_23_0_
  start = v_23_0_
end
local lesson_1 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function lesson_10()
      append({"", ";; Good job!", ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation.", ";; All results are appended to the log buffer, when you don't have the log open the HUD will appear.", ";; The HUD closes automatically when you move your cursor.", "", (";; You can open the log buffer horizontally (" .. map_str("log-split") .. "), vertically (" .. map_str("log-vsplit") .. ") or in a tab (" .. map_str("log-tab") .. ")."), (";; All visible log windows (including the HUD) can be closed with " .. map_str("log-close-visible")), ";; Try opening and closing the log window to get the hang of it now.", ";; It's a regular window and buffer, so you can edit and close it however you want!", ";; Feel free to leave it open in a split for the next lesson to see how it behaves.", "", ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment.", (";; Place your cursor on the inner form (the one inside the comment) and use " .. map_str("eval-current-form") .. " to evaluate it."), "(comment", "  (school.lesson-2))"})
      return progress(1)
    end
    v_23_0_0 = lesson_10
    _0_0["lesson-1"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["lesson-1"] = v_23_0_
  lesson_1 = v_23_0_
end
local lesson_2 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function lesson_20()
      append({"", ";; Awesome! You evaluated the form under your cursor.", (";; If we want to evaluate the outermost form under our cursor, we can use " .. map_str("eval-root-form") .. " instead."), ";; Try that below to print some output and advance to the next lesson.", ";; You can place your cursor anywhere inside the (do ...) form.", "(do", "  (print \"Hello, World!\")", "  (school.lesson-3))"})
      return progress(2)
    end
    v_23_0_0 = lesson_20
    _0_0["lesson-2"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["lesson-2"] = v_23_0_
  lesson_2 = v_23_0_
end
local lesson_3 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function lesson_30()
      append({})
      return progress(3)
    end
    v_23_0_0 = lesson_30
    _0_0["lesson-3"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["lesson-3"] = v_23_0_
  lesson_3 = v_23_0_
end
return nil