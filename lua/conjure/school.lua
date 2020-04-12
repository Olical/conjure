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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", config = "conjure.config", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.config"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local a = _2_[1]
local buffer = _2_[2]
local config = _2_[3]
local nvim = _2_[4]
do local _ = ({nil, _0_0, nil})[2] end
local log_buf_name = nil
do
  local v_23_0_ = "conjure-school.fnl"
  _0_0["aniseed/locals"]["log-buf-name"] = v_23_0_
  log_buf_name = v_23_0_
end
local upsert_buf = nil
do
  local v_23_0_ = nil
  local function upsert_buf0()
    return buffer["upsert-hidden"](log_buf_name)
  end
  v_23_0_ = upsert_buf0
  _0_0["aniseed/locals"]["upsert-buf"] = v_23_0_
  upsert_buf = v_23_0_
end
local go_to_bottom = nil
do
  local v_23_0_ = nil
  local function go_to_bottom0(buf)
    return nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
  end
  v_23_0_ = go_to_bottom0
  _0_0["aniseed/locals"]["go-to-bottom"] = v_23_0_
  go_to_bottom = v_23_0_
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
local start = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function start0()
      local buf = upsert_buf()
      nvim.ex.edit(log_buf_name)
      nvim.buf_set_lines(buf, 0, -1, false, {})
      return append({"(module user.conjure-school", "  {require {school conjure.school}})", "", ";; Welcome to Conjure school!", ";; Run :ConjureSchool again at any time to start fresh.", ";; This is a Fennel buffer, we can evaluate parts of it using Conjure.", ";; Conjure will compile the Fennel to Lua and execute it within Neovim's process.", (";; Try evaluating this buffer with " .. map_str("eval-buf")), "(school.lesson-1)"})
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
      return append({"", ";; Congratulations, you just evaluated this code!", ";; Notice how a window appeared with a `nil` inside it? That's the log HUD.", ";; The log will retain a list of your requests and their results.", ";; The HUD allows us to see what's going on in the log when we're not watching.", ";; We can open that buffer and edit it to our hearts content, it's a normal buffer!", ";; We can even evaluate code from inside the buffer itself, just like a REPL.", "", (";; The HUD will close when you move your cursor or hit " .. map_str("close-hud")), (";; You can open the log vertically (" .. map_str("log-vsplit") .. ") or horizontally (" .. map_str("log-split") .. ")."), (";; For a full screen experience, a new tab may be better. (" .. map_str("log-tab") .. ")."), ";; Give some of those a go, you can just close the log window as you normally would."})
    end
    v_23_0_0 = lesson_10
    _0_0["lesson-1"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["lesson-1"] = v_23_0_
  lesson_1 = v_23_0_
end
return nil