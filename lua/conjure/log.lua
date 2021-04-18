local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.log"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.nvim"), require("conjure.sponsors"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.timer"), require("conjure.aniseed.view")}
local a = _local_0_[1]
local timer = _local_0_[10]
local view = _local_0_[11]
local buffer = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local editor = _local_0_[5]
local nvim = _local_0_[6]
local sponsors = _local_0_[7]
local str = _local_0_[8]
local text = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.log"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state = {hud = {id = nil, timer = nil}}
local function _break()
  return (client.get("comment-prefix") .. string.rep("-", config["get-in"]({"log", "break_length"})))
end
local function state_key_header()
  return (client.get("comment-prefix") .. "State: " .. client["state-key"]())
end
local function log_buf_name()
  return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
end
local log_buf_3f
do
  local v_0_
  local function log_buf_3f0(name)
    return name:match((log_buf_name() .. "$"))
  end
  v_0_ = log_buf_3f0
  _0_0["log-buf?"] = v_0_
  log_buf_3f = v_0_
end
local function on_new_log_buf(buf)
  return nvim.buf_set_lines(buf, 0, -1, false, {(client.get("comment-prefix") .. "Sponsored by @" .. a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))) .. " \226\157\164")})
end
local function upsert_buf()
  return buffer["upsert-hidden"](log_buf_name(), on_new_log_buf)
end
local clear_close_hud_passive_timer
do
  local v_0_
  local function clear_close_hud_passive_timer0()
    return a["update-in"](state, {"hud", "timer"}, timer.destroy)
  end
  v_0_ = clear_close_hud_passive_timer0
  _0_0["clear-close-hud-passive-timer"] = v_0_
  clear_close_hud_passive_timer = v_0_
end
local close_hud
do
  local v_0_
  local function close_hud0()
    clear_close_hud_passive_timer()
    if state.hud.id then
      pcall(nvim.win_close, state.hud.id, true)
      state.hud.id = nil
      return nil
    end
  end
  v_0_ = close_hud0
  _0_0["close-hud"] = v_0_
  close_hud = v_0_
end
local close_hud_passive
do
  local v_0_
  local function close_hud_passive0()
    if state.hud.id then
      local original_timer_id = state.hud["timer-id"]
      local delay = config["get-in"]({"log", "hud", "passive_close_delay"})
      if (0 == delay) then
        return close_hud()
      else
        if not a["get-in"](state, {"hud", "timer"}) then
          return a["assoc-in"](state, {"hud", "timer"}, timer.defer(close_hud, delay))
        end
      end
    end
  end
  v_0_ = close_hud_passive0
  _0_0["close-hud-passive"] = v_0_
  close_hud_passive = v_0_
end
local function break_lines(buf)
  local break_str = _break()
  local function _2_(_1_0)
    local _arg_0_ = _1_0
    local n = _arg_0_[1]
    local s = _arg_0_[2]
    return (s == break_str)
  end
  return a.map(a.first, a.filter(_2_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
end
local function set_win_opts_21(win)
  local function _1_()
    if config["get-in"]({"log", "wrap"}) then
      return true
    else
      return false
    end
  end
  nvim.win_set_option(win, "wrap", _1_())
  nvim.win_set_option(win, "foldmethod", "marker")
  nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
  return nvim.win_set_option(win, "foldlevel", 0)
end
local function in_box_3f(box, pos)
  return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
end
local function flip_anchor(anchor, n)
  local chars = {anchor:sub(1, 1), anchor:sub(2)}
  local flip = {E = "W", N = "S", S = "N", W = "E"}
  local function _1_(_241)
    return a.get(flip, _241)
  end
  return str.join(a.update(chars, n, _1_))
end
local function pad_box(box, padding)
  local function _1_(_241)
    return (_241 - padding.x)
  end
  local function _2_(_241)
    return (_241 - padding.y)
  end
  local function _3_(_241)
    return (_241 + padding.x)
  end
  local function _4_(_241)
    return (_241 + padding.y)
  end
  return a.update(a.update(a.update(a.update(box, "x1", _1_), "y1", _2_), "x2", _3_), "y2", _4_)
end
local function hud_window_pos(anchor, size, rec_3f)
  local north = 0
  local west = 0
  local south = (editor.height() - 2)
  local east = editor.width()
  local padding_percent = config["get-in"]({"log", "hud", "overlap_padding"})
  local pos
  local _1_
  if ("NE" == anchor) then
    _1_ = {box = {x1 = (east - size.width), x2 = east, y1 = north, y2 = (north + size.height)}, col = east, row = north}
  elseif ("SE" == anchor) then
    _1_ = {box = {x1 = (east - size.width), x2 = east, y1 = (south - size.height), y2 = south}, col = east, row = south}
  elseif ("SW" == anchor) then
    _1_ = {box = {x1 = west, x2 = (west + size.width), y1 = (south - size.height), y2 = south}, col = west, row = south}
  elseif ("NW" == anchor) then
    _1_ = {box = {x1 = west, x2 = (west + size.width), y1 = north, y2 = (north + size.height)}, col = west, row = north}
  else
    nvim.err_writeln("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
    _1_ = hud_window_pos("NE", size)
  end
  pos = a.assoc(_1_, "anchor", anchor)
  if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
    local function _3_()
      if (size.width > size.height) then
        return 1
      else
        return 2
      end
    end
    return hud_window_pos(flip_anchor(anchor, _3_()), size, true)
  else
    return pos
  end
end
local function display_hud()
  if config["get-in"]({"log", "hud", "enabled"}) then
    clear_close_hud_passive_timer()
    local buf = upsert_buf()
    local last_break = a.last(break_lines(buf))
    local line_count = nvim.buf_line_count(buf)
    local size = {height = editor["percent-height"](config["get-in"]({"log", "hud", "height"})), width = editor["percent-width"](config["get-in"]({"log", "hud", "width"}))}
    local pos = hud_window_pos(config["get-in"]({"log", "hud", "anchor"}), size)
    local win_opts = {anchor = pos.anchor, col = pos.col, focusable = false, height = size.height, relative = "editor", row = pos.row, style = "minimal", width = size.width}
    if not nvim.win_is_valid(state.hud.id) then
      close_hud()
    end
    if state.hud.id then
      nvim.win_set_buf(state.hud.id, buf)
    else
      state.hud.id = nvim.open_win(buf, false, win_opts)
      set_win_opts_21(state.hud.id)
    end
    if last_break then
      nvim.win_set_cursor(state.hud.id, {1, 0})
      return nvim.win_set_cursor(state.hud.id, {math.min((last_break + a.inc(math.floor((win_opts.height / 2)))), line_count), 0})
    else
      return nvim.win_set_cursor(state.hud.id, {line_count, 0})
    end
  end
end
local function win_visible_3f(win)
  return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
end
local function with_buf_wins(buf, f)
  local function _1_(win)
    if (buf == nvim.win_get_buf(win)) then
      return f(win)
    end
  end
  return a["run!"](_1_, nvim.list_wins())
end
local function win_botline(win)
  return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
end
local function trim(buf)
  local line_count = nvim.buf_line_count(buf)
  if (line_count > config["get-in"]({"log", "trim", "at"})) then
    local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
    local break_line
    local function _1_(line)
      if (line >= target_line_count) then
        return line
      end
    end
    break_line = a.some(_1_, break_lines(buf))
    if break_line then
      nvim.buf_set_lines(buf, 0, break_line, false, {})
      local line_count0 = nvim.buf_line_count(buf)
      local function _2_(win)
        local _let_0_ = nvim.win_get_cursor(win)
        local row = _let_0_[1]
        local col = _let_0_[2]
        nvim.win_set_cursor(win, {1, 0})
        return nvim.win_set_cursor(win, {row, col})
      end
      return with_buf_wins(buf, _2_)
    end
  end
end
local last_line
do
  local v_0_
  local function last_line0(buf, extra_offset)
    return a.first(nvim.buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
  end
  v_0_ = last_line0
  _0_0["last-line"] = v_0_
  last_line = v_0_
end
local append
do
  local v_0_
  local function append0(lines, opts)
    local line_count = a.count(lines)
    if (line_count > 0) then
      local visible_scrolling_log_3f = false
      local buf = upsert_buf()
      local join_first_3f = a.get(opts, "join-first?")
      local lines0
      local function _1_(s)
        return s:gsub("\n", "\226\134\181")
      end
      lines0 = a.map(_1_, lines)
      local lines1
      if (line_count <= config["get-in"]({"log", "strip_ansi_escape_sequences_line_limit"})) then
        lines1 = a.map(text["strip-ansi-escape-sequences"], lines0)
      else
        lines1 = lines0
      end
      local comment_prefix = client.get("comment-prefix")
      local fold_marker_end = str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "end"})})
      local lines2
      if (not a.get(opts, "break?") and not join_first_3f and config["get-in"]({"log", "fold", "enabled"}) and (a.count(lines1) >= config["get-in"]({"log", "fold", "lines"}))) then
        lines2 = a.concat({str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "start"}), " ", text["left-sample"](str.join("\n", lines1), editor["percent-width"](config["get-in"]({"preview", "sample_limit"})))})}, lines1, {fold_marker_end})
      else
        lines2 = lines1
      end
      local last_fold_3f = (fold_marker_end == last_line(buf))
      local lines3
      if a.get(opts, "break?") then
        local _4_
        if client["multiple-states?"]() then
          _4_ = {state_key_header()}
        else
        _4_ = nil
        end
        lines3 = a.concat({_break()}, _4_, lines2)
      elseif join_first_3f then
        local _4_
        if last_fold_3f then
          _4_ = {(last_line(buf, -1) .. a.first(lines2)), fold_marker_end}
        else
          _4_ = {(last_line(buf) .. a.first(lines2))}
        end
        lines3 = a.concat(_4_, a.rest(lines2))
      else
        lines3 = lines2
      end
      local old_lines = nvim.buf_line_count(buf)
      do
        local ok_3f, err = nil, nil
        local function _5_()
          local _6_
          if buffer["empty?"](buf) then
            _6_ = 0
          elseif join_first_3f then
            if last_fold_3f then
              _6_ = -3
            else
              _6_ = -2
            end
          else
            _6_ = -1
          end
          return nvim.buf_set_lines(buf, _6_, -1, false, lines3)
        end
        ok_3f, err = pcall(_5_)
        if not ok_3f then
          error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a["pr-str"](lines3)))
        end
      end
      do
        local new_lines = nvim.buf_line_count(buf)
        local function _5_(win)
          local _let_0_ = nvim.win_get_cursor(win)
          local row = _let_0_[1]
          local col = _let_0_[2]
          if ((win ~= state.hud.id) and win_visible_3f(win) and (win_botline(win) >= old_lines)) then
            visible_scrolling_log_3f = true
          end
          if (row == old_lines) then
            return nvim.win_set_cursor(win, {new_lines, 0})
          end
        end
        with_buf_wins(buf, _5_)
      end
      if (not a.get(opts, "suppress-hud?") and not visible_scrolling_log_3f) then
        display_hud()
      else
        close_hud()
      end
      return trim(buf)
    end
  end
  v_0_ = append0
  _0_0["append"] = v_0_
  append = v_0_
end
local function create_win(cmd)
  local buf = upsert_buf()
  local _1_
  if config["get-in"]({"log", "botright"}) then
    _1_ = "botright "
  else
    _1_ = ""
  end
  nvim.command(("keepalt " .. _1_ .. cmd .. " " .. buffer.resolve(log_buf_name())))
  nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
  set_win_opts_21(0)
  return buffer.unlist(buf)
end
local split
do
  local v_0_
  local function split0()
    return create_win("split")
  end
  v_0_ = split0
  _0_0["split"] = v_0_
  split = v_0_
end
local vsplit
do
  local v_0_
  local function vsplit0()
    return create_win("vsplit")
  end
  v_0_ = vsplit0
  _0_0["vsplit"] = v_0_
  vsplit = v_0_
end
local tab
do
  local v_0_
  local function tab0()
    return create_win("tabnew")
  end
  v_0_ = tab0
  _0_0["tab"] = v_0_
  tab = v_0_
end
local close_visible
do
  local v_0_
  local function close_visible0()
    local buf = upsert_buf()
    close_hud()
    local function _1_(_241)
      return nvim.win_close(_241, true)
    end
    local function _2_(win)
      return (buf == nvim.win_get_buf(win))
    end
    return a["run!"](_1_, a.filter(_2_, nvim.tabpage_list_wins(0)))
  end
  v_0_ = close_visible0
  _0_0["close-visible"] = v_0_
  close_visible = v_0_
end
local dbg
do
  local v_0_
  local function dbg0(desc, ...)
    if config["get-in"]({"debug"}) then
      append(a.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](a["pr-str"](...))))
    end
    return ...
  end
  v_0_ = dbg0
  _0_0["dbg"] = v_0_
  dbg = v_0_
end
local reset_soft
do
  local v_0_
  local function reset_soft0()
    return on_new_log_buf(upsert_buf())
  end
  v_0_ = reset_soft0
  _0_0["reset-soft"] = v_0_
  reset_soft = v_0_
end
local reset_hard
do
  local v_0_
  local function reset_hard0()
    return nvim.ex.bwipeout_(upsert_buf())
  end
  v_0_ = reset_hard0
  _0_0["reset-hard"] = v_0_
  reset_hard = v_0_
end
return nil