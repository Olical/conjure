local _0_0 = nil
do
  local name_23_0_ = "conjure.log"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim", text = "conjure.text", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.nvim"), require("conjure.text"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local buffer = _2_[2]
local client = _2_[3]
local config = _2_[4]
local editor = _2_[5]
local nvim = _2_[6]
local text = _2_[7]
local view = _2_[8]
do local _ = ({nil, _0_0, nil})[2] end
local current_timer_id = 0
local state = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"].state or {hud = {id = nil}})
  _0_0["aniseed/locals"]["state"] = v_23_0_
  state = v_23_0_
end
local _break = nil
do
  local v_23_0_ = nil
  local function _break0()
    return (client.get("comment-prefix") .. string.rep("-", config.log["break-length"]))
  end
  v_23_0_ = _break0
  _0_0["aniseed/locals"]["break"] = v_23_0_
  _break = v_23_0_
end
local log_buf_name = nil
do
  local v_23_0_ = nil
  local function log_buf_name0()
    return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
  end
  v_23_0_ = log_buf_name0
  _0_0["aniseed/locals"]["log-buf-name"] = v_23_0_
  log_buf_name = v_23_0_
end
local upsert_buf = nil
do
  local v_23_0_ = nil
  local function upsert_buf0()
    return buffer["upsert-hidden"](log_buf_name())
  end
  v_23_0_ = upsert_buf0
  _0_0["aniseed/locals"]["upsert-buf"] = v_23_0_
  upsert_buf = v_23_0_
end
local close_hud = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_hud0()
      if state.hud.id then
        local function _3_()
          nvim.win_close(state.hud.id, true)
          state.hud.id = nil
          return nil
        end
        return pcall(_3_)
      end
    end
    v_23_0_0 = close_hud0
    _0_0["close-hud"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-hud"] = v_23_0_
  close_hud = v_23_0_
end
local defer_close_hud = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function defer_close_hud0()
      local my_id = current_timer_id
      if state.hud.id then
        local function _3_()
          if (my_id == current_timer_id) then
            return close_hud()
          end
        end
        return vim.defer_fn(_3_, 1000)
      end
    end
    v_23_0_0 = defer_close_hud0
    _0_0["defer-close-hud"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["defer-close-hud"] = v_23_0_
  defer_close_hud = v_23_0_
end
local break_lines = nil
do
  local v_23_0_ = nil
  local function break_lines0(buf)
    local break_str = _break()
    local function _3_(_4_0)
      local _5_ = _4_0
      local n = _5_[1]
      local s = _5_[2]
      return (s == break_str)
    end
    return a.map(a.first, a.filter(_3_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
  end
  v_23_0_ = break_lines0
  _0_0["aniseed/locals"]["break-lines"] = v_23_0_
  break_lines = v_23_0_
end
local display_hud = nil
do
  local v_23_0_ = nil
  local function display_hud0()
    if config.log.hud["enabled?"] then
      current_timer_id = (current_timer_id + 1)
      local buf = upsert_buf()
      local cursor_top_right_3f = ((editor["cursor-left"]() > editor["percent-width"](0.5)) and (editor["cursor-top"]() < editor["percent-height"](0.5)))
      local last_break = a.last(break_lines(buf))
      local line_count = nvim.buf_line_count(buf)
      local win_opts = nil
      local _3_
      if cursor_top_right_3f then
        _3_ = (editor.height() - 2)
      else
        _3_ = 0
      end
      win_opts = {anchor = "SE", col = editor.width(), focusable = false, height = editor["percent-height"](config.log.hud.height), relative = "editor", row = _3_, style = "minimal", width = editor["percent-width"](config.log.hud.width)}
      if not state.hud.id then
        state.hud.id = nvim.open_win(buf, false, win_opts)
        nvim.win_set_option(state.hud.id, "wrap", false)
      end
      if last_break then
        nvim.win_set_cursor(state.hud.id, {1, 0})
        return nvim.win_set_cursor(state.hud.id, {math.min((last_break + a.inc(math.floor((win_opts.height / 2)))), line_count), 0})
      else
        return nvim.win_set_cursor(state.hud.id, {line_count, 0})
      end
    end
  end
  v_23_0_ = display_hud0
  _0_0["aniseed/locals"]["display-hud"] = v_23_0_
  display_hud = v_23_0_
end
local win_visible_3f = nil
do
  local v_23_0_ = nil
  local function win_visible_3f0(win)
    return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
  end
  v_23_0_ = win_visible_3f0
  _0_0["aniseed/locals"]["win-visible?"] = v_23_0_
  win_visible_3f = v_23_0_
end
local with_buf_wins = nil
do
  local v_23_0_ = nil
  local function with_buf_wins0(buf, f)
    local function _3_(win)
      if (buf == nvim.win_get_buf(win)) then
        return f(win)
      end
    end
    return a["run!"](_3_, nvim.list_wins())
  end
  v_23_0_ = with_buf_wins0
  _0_0["aniseed/locals"]["with-buf-wins"] = v_23_0_
  with_buf_wins = v_23_0_
end
local win_botline = nil
do
  local v_23_0_ = nil
  local function win_botline0(win)
    return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
  end
  v_23_0_ = win_botline0
  _0_0["aniseed/locals"]["win-botline"] = v_23_0_
  win_botline = v_23_0_
end
local trim = nil
do
  local v_23_0_ = nil
  local function trim0(buf)
    local line_count = nvim.buf_line_count(buf)
    if (line_count > config.log.trim.at) then
      local target_line_count = (line_count - config.log.trim.to)
      local break_line = nil
      local function _3_(line)
        if (line >= target_line_count) then
          return line
        end
      end
      break_line = a.some(_3_, break_lines(buf))
      if break_line then
        nvim.buf_set_lines(buf, 0, break_line, false, {})
        local line_count0 = nvim.buf_line_count(buf)
        local function _4_(win)
          local _5_ = nvim.win_get_cursor(win)
          local row = _5_[1]
          local col = _5_[2]
          nvim.win_set_cursor(win, {1, 0})
          return nvim.win_set_cursor(win, {row, col})
        end
        return with_buf_wins(buf, _4_)
      end
    end
  end
  v_23_0_ = trim0
  _0_0["aniseed/locals"]["trim"] = v_23_0_
  trim = v_23_0_
end
local last_line = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function last_line0(buf)
      return a.first(nvim.buf_get_lines((buf or upsert_buf()), -2, -1, false))
    end
    v_23_0_0 = last_line0
    _0_0["last-line"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["last-line"] = v_23_0_
  last_line = v_23_0_
end
local append = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function append0(lines, opts)
      if not a["empty?"](lines) then
        local visible_scrolling_log_3f = false
        local buf = upsert_buf()
        local join_first_3f = a.get(opts, "join-first?")
        local lines0 = nil
        if a.get(opts, "break?") then
          lines0 = a.concat({_break()}, lines)
        elseif join_first_3f then
          lines0 = a.concat({(last_line(buf) .. a.first(lines))}, a.rest(lines))
        else
          lines0 = lines
        end
        local old_lines = nvim.buf_line_count(buf)
        local _4_
        if buffer["empty?"](buf) then
          _4_ = 0
        elseif join_first_3f then
          _4_ = -2
        else
          _4_ = -1
        end
        nvim.buf_set_lines(buf, _4_, -1, false, lines0)
        do
          local new_lines = nvim.buf_line_count(buf)
          local function _6_(win)
            local _7_ = nvim.win_get_cursor(win)
            local row = _7_[1]
            local col = _7_[2]
            if ((win ~= state.hud.id) and win_visible_3f(win) and (win_botline(win) >= old_lines)) then
              visible_scrolling_log_3f = true
            end
            if (row == old_lines) then
              return nvim.win_set_cursor(win, {new_lines, 0})
            end
          end
          with_buf_wins(buf, _6_)
        end
        if (not a.get(opts, "suppress-hud?") and not visible_scrolling_log_3f) then
          display_hud()
        else
          close_hud()
        end
        return trim(buf)
      end
    end
    v_23_0_0 = append0
    _0_0["append"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["append"] = v_23_0_
  append = v_23_0_
end
local create_win = nil
do
  local v_23_0_ = nil
  local function create_win0(cmd)
    local buf = upsert_buf()
    local function _3_()
      if a["get-in"](config, {"log", "botright?"}) then
        return "botright "
      else
        return ""
      end
    end
    nvim.command((_3_() .. cmd .. " " .. log_buf_name()))
    nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
    nvim.win_set_option(0, "wrap", false)
    return buffer.unlist(buf)
  end
  v_23_0_ = create_win0
  _0_0["aniseed/locals"]["create-win"] = v_23_0_
  create_win = v_23_0_
end
local split = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function split0()
      return create_win("split")
    end
    v_23_0_0 = split0
    _0_0["split"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["split"] = v_23_0_
  split = v_23_0_
end
local vsplit = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function vsplit0()
      return create_win("vsplit")
    end
    v_23_0_0 = vsplit0
    _0_0["vsplit"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["vsplit"] = v_23_0_
  vsplit = v_23_0_
end
local tab = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function tab0()
      return create_win("tabnew")
    end
    v_23_0_0 = tab0
    _0_0["tab"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["tab"] = v_23_0_
  tab = v_23_0_
end
local close_visible = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_visible0()
      local buf = upsert_buf()
      close_hud()
      local function _3_(_241)
        return nvim.win_close(_241, true)
      end
      local function _4_(win)
        return (buf == nvim.win_get_buf(win))
      end
      return a["run!"](_3_, a.filter(_4_, nvim.tabpage_list_wins(0)))
    end
    v_23_0_0 = close_visible0
    _0_0["close-visible"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-visible"] = v_23_0_
  close_visible = v_23_0_
end
local dbg = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function dbg0(desc, data)
      if (config["debug?"] or client.get("config", "debug?")) then
        append(a.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](view.serialise(data))))
      end
      return data
    end
    v_23_0_0 = dbg0
    _0_0["dbg"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["dbg"] = v_23_0_
  dbg = v_23_0_
end
return nil