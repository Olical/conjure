local _2afile_2a = "fnl/conjure/log.fnl"
local _2amodule_name_2a = "conjure.log"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, buffer, client, config, editor, nvim, str, text, timer, view, sponsors = autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.aniseed.view"), require("conjure.sponsors")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["buffer"] = buffer
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["view"] = view
_2amodule_locals_2a["sponsors"] = sponsors
local state = (state or {["last-open-cmd"] = nil, hud = {id = nil, timer = nil, ["created-at-ms"] = 0}, ["jump-to-latest"] = {mark = nil, ns = nvim.create_namespace("conjure_log_jump_to_latest")}})
do end (_2amodule_locals_2a)["state"] = state
local function _break()
  return (client.get("comment-prefix") .. string.rep("-", config["get-in"]({"log", "break_length"})))
end
_2amodule_locals_2a["break"] = _break
local function state_key_header()
  return (client.get("comment-prefix") .. "State: " .. client["state-key"]())
end
_2amodule_locals_2a["state-key-header"] = state_key_header
local function log_buf_name()
  return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
end
_2amodule_locals_2a["log-buf-name"] = log_buf_name
local function log_buf_3f(name)
  return text["ends-with"](name, log_buf_name())
end
_2amodule_2a["log-buf?"] = log_buf_3f
local function on_new_log_buf(buf)
  state["jump-to-latest"].mark = nvim.buf_set_extmark(buf, state["jump-to-latest"].ns, 0, 0, {})
  return nvim.buf_set_lines(buf, 0, -1, false, {(client.get("comment-prefix") .. "Sponsored by @" .. a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))) .. " \226\157\164")})
end
_2amodule_locals_2a["on-new-log-buf"] = on_new_log_buf
local function upsert_buf()
  return buffer["upsert-hidden"](log_buf_name(), on_new_log_buf)
end
_2amodule_locals_2a["upsert-buf"] = upsert_buf
local function clear_close_hud_passive_timer()
  return a["update-in"](state, {"hud", "timer"}, timer.destroy)
end
_2amodule_2a["clear-close-hud-passive-timer"] = clear_close_hud_passive_timer
local function close_hud()
  clear_close_hud_passive_timer()
  if state.hud.id then
    pcall(nvim.win_close, state.hud.id, true)
    state.hud.id = nil
    return nil
  else
    return nil
  end
end
_2amodule_2a["close-hud"] = close_hud
local function hud_lifetime_ms()
  return (vim.loop.now() - state.hud["created-at-ms"])
end
_2amodule_2a["hud-lifetime-ms"] = hud_lifetime_ms
local function close_hud_passive()
  if (state.hud.id and (hud_lifetime_ms() > config["get-in"]({"log", "hud", "minimum_lifetime_ms"}))) then
    local original_timer_id = state.hud["timer-id"]
    local delay = config["get-in"]({"log", "hud", "passive_close_delay"})
    if (0 == delay) then
      return close_hud()
    else
      if not a["get-in"](state, {"hud", "timer"}) then
        return a["assoc-in"](state, {"hud", "timer"}, timer.defer(close_hud, delay))
      else
        return nil
      end
    end
  else
    return nil
  end
end
_2amodule_2a["close-hud-passive"] = close_hud_passive
local function break_lines(buf)
  local break_str = _break()
  local function _7_(_5_)
    local _arg_6_ = _5_
    local n = _arg_6_[1]
    local s = _arg_6_[2]
    return (s == break_str)
  end
  return a.map(a.first, a.filter(_7_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
end
_2amodule_locals_2a["break-lines"] = break_lines
local function set_win_opts_21(win)
  local function _8_()
    if config["get-in"]({"log", "wrap"}) then
      return true
    else
      return false
    end
  end
  nvim.win_set_option(win, "wrap", _8_())
  nvim.win_set_option(win, "foldmethod", "marker")
  nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
  return nvim.win_set_option(win, "foldlevel", 0)
end
_2amodule_locals_2a["set-win-opts!"] = set_win_opts_21
local function in_box_3f(box, pos)
  return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
end
_2amodule_locals_2a["in-box?"] = in_box_3f
local function flip_anchor(anchor, n)
  local chars = {anchor:sub(1, 1), anchor:sub(2)}
  local flip = {N = "S", S = "N", E = "W", W = "E"}
  local function _9_(_241)
    return a.get(flip, _241)
  end
  return str.join(a.update(chars, n, _9_))
end
_2amodule_locals_2a["flip-anchor"] = flip_anchor
local function pad_box(box, padding)
  local function _10_(_241)
    return (_241 - padding.x)
  end
  local function _11_(_241)
    return (_241 - padding.y)
  end
  local function _12_(_241)
    return (_241 + padding.x)
  end
  local function _13_(_241)
    return (_241 + padding.y)
  end
  return a.update(a.update(a.update(a.update(box, "x1", _10_), "y1", _11_), "x2", _12_), "y2", _13_)
end
_2amodule_locals_2a["pad-box"] = pad_box
local function hud_window_pos(anchor, size, rec_3f)
  local north = 0
  local west = 0
  local south = (editor.height() - 2)
  local east = editor.width()
  local padding_percent = config["get-in"]({"log", "hud", "overlap_padding"})
  local pos
  local _14_
  if ("NE" == anchor) then
    _14_ = {row = north, col = east, box = {y1 = north, x1 = (east - size.width), y2 = (north + size.height), x2 = east}}
  elseif ("SE" == anchor) then
    _14_ = {row = south, col = east, box = {y1 = (south - size.height), x1 = (east - size.width), y2 = south, x2 = east}}
  elseif ("SW" == anchor) then
    _14_ = {row = south, col = west, box = {y1 = (south - size.height), x1 = west, y2 = south, x2 = (west + size.width)}}
  elseif ("NW" == anchor) then
    _14_ = {row = north, col = west, box = {y1 = north, x1 = west, y2 = (north + size.height), x2 = (west + size.width)}}
  else
    nvim.err_writeln("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
    _14_ = hud_window_pos("NE", size)
  end
  pos = a.assoc(_14_, "anchor", anchor)
  if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
    local function _16_()
      if (size.width > size.height) then
        return 1
      else
        return 2
      end
    end
    return hud_window_pos(flip_anchor(anchor, _16_()), size, true)
  else
    return pos
  end
end
_2amodule_locals_2a["hud-window-pos"] = hud_window_pos
local function display_hud()
  if config["get-in"]({"log", "hud", "enabled"}) then
    clear_close_hud_passive_timer()
    local buf = upsert_buf()
    local last_break = a.last(break_lines(buf))
    local line_count = nvim.buf_line_count(buf)
    local size = {width = editor["percent-width"](config["get-in"]({"log", "hud", "width"})), height = editor["percent-height"](config["get-in"]({"log", "hud", "height"}))}
    local pos = hud_window_pos(config["get-in"]({"log", "hud", "anchor"}), size)
    local border = config["get-in"]({"log", "hud", "border"})
    local win_opts
    local function _18_()
      if (1 == nvim.fn.has("nvim-0.5")) then
        return {border = border}
      else
        return nil
      end
    end
    win_opts = a.merge({relative = "editor", row = pos.row, col = pos.col, anchor = pos.anchor, width = size.width, height = size.height, focusable = false, style = "minimal"}, _18_())
    if (state.hud.id and not nvim.win_is_valid(state.hud.id)) then
      close_hud()
    else
    end
    if state.hud.id then
      nvim.win_set_buf(state.hud.id, buf)
    else
      state.hud.id = nvim.open_win(buf, false, win_opts)
      set_win_opts_21(state.hud.id)
    end
    state.hud["created-at-ms"] = vim.loop.now()
    if last_break then
      nvim.win_set_cursor(state.hud.id, {1, 0})
      return nvim.win_set_cursor(state.hud.id, {math.min((last_break + a.inc(math.floor((win_opts.height / 2)))), line_count), 0})
    else
      return nvim.win_set_cursor(state.hud.id, {line_count, 0})
    end
  else
    return nil
  end
end
_2amodule_locals_2a["display-hud"] = display_hud
local function win_visible_3f(win)
  return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
end
_2amodule_locals_2a["win-visible?"] = win_visible_3f
local function with_buf_wins(buf, f)
  local function _23_(win)
    if (buf == nvim.win_get_buf(win)) then
      return f(win)
    else
      return nil
    end
  end
  return a["run!"](_23_, nvim.list_wins())
end
_2amodule_locals_2a["with-buf-wins"] = with_buf_wins
local function win_botline(win)
  return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
end
_2amodule_locals_2a["win-botline"] = win_botline
local function trim(buf)
  local line_count = nvim.buf_line_count(buf)
  if (line_count > config["get-in"]({"log", "trim", "at"})) then
    local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
    local break_line
    local function _25_(line)
      if (line >= target_line_count) then
        return line
      else
        return nil
      end
    end
    break_line = a.some(_25_, break_lines(buf))
    if break_line then
      nvim.buf_set_lines(buf, 0, break_line, false, {})
      local line_count0 = nvim.buf_line_count(buf)
      local function _27_(win)
        local _let_28_ = nvim.win_get_cursor(win)
        local row = _let_28_[1]
        local col = _let_28_[2]
        nvim.win_set_cursor(win, {1, 0})
        return nvim.win_set_cursor(win, {row, col})
      end
      return with_buf_wins(buf, _27_)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_locals_2a["trim"] = trim
local function last_line(buf, extra_offset)
  return a.first(nvim.buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
end
_2amodule_2a["last-line"] = last_line
local cursor_scroll_position__3ecommand = {top = "normal zt", center = "normal zz", bottom = "normal zb", none = nil}
_2amodule_2a["cursor-scroll-position->command"] = cursor_scroll_position__3ecommand
local function jump_to_latest()
  local buf = upsert_buf()
  local last_eval_start = nvim.buf_get_extmark_by_id(buf, state["jump-to-latest"].ns, state["jump-to-latest"].mark, {})
  local function _31_(win)
    nvim.win_set_cursor(win, last_eval_start)
    local cmd = a.get(cursor_scroll_position__3ecommand, config["get-in"]({"log", "jump_to_latest", "cursor_scroll_position"}))
    if cmd then
      local function _32_()
        return nvim.command(cmd)
      end
      return nvim.win_call(win, _32_)
    else
      return nil
    end
  end
  return with_buf_wins(buf, _31_)
end
_2amodule_2a["jump-to-latest"] = jump_to_latest
local function append(lines, opts)
  local line_count = a.count(lines)
  if (line_count > 0) then
    local visible_scrolling_log_3f = false
    local buf = upsert_buf()
    local join_first_3f = a.get(opts, "join-first?")
    local lines0
    local function _34_(s)
      return s:gsub("\n", "\226\134\181")
    end
    lines0 = a.map(_34_, lines)
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
      local _37_
      if client["multiple-states?"]() then
        _37_ = {state_key_header()}
      else
        _37_ = nil
      end
      lines3 = a.concat({_break()}, _37_, lines2)
    elseif join_first_3f then
      local _39_
      if last_fold_3f then
        _39_ = {(last_line(buf, -1) .. a.first(lines2)), fold_marker_end}
      else
        _39_ = {(last_line(buf) .. a.first(lines2))}
      end
      lines3 = a.concat(_39_, a.rest(lines2))
    else
      lines3 = lines2
    end
    local old_lines = nvim.buf_line_count(buf)
    local new_line_index
    if buffer["empty?"](buf) then
      new_line_index = 0
    elseif join_first_3f then
      if last_fold_3f then
        new_line_index = -3
      else
        new_line_index = -2
      end
    else
      new_line_index = -1
    end
    do
      local ok_3f, err = nil, nil
      local function _44_()
        return nvim.buf_set_lines(buf, new_line_index, -1, false, lines3)
      end
      ok_3f, err = pcall(_44_)
      if not ok_3f then
        error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a["pr-str"](lines3)))
      else
      end
    end
    do
      local new_lines = nvim.buf_line_count(buf)
      local jump_to_latest_3f = config["get-in"]({"log", "jump_to_latest", "enabled"})
      nvim.buf_set_extmark(buf, state["jump-to-latest"].ns, (new_line_index + old_lines + 2), 0, {id = state["jump-to-latest"].mark})
      local function _46_(win)
        visible_scrolling_log_3f = ((win ~= state.hud.id) and win_visible_3f(win) and (jump_to_latest_3f or (win_botline(win) >= old_lines)))
        local _let_47_ = nvim.win_get_cursor(win)
        local row = _let_47_[1]
        local _ = _let_47_[2]
        if jump_to_latest_3f then
          return jump_to_latest()
        elseif (row == old_lines) then
          return nvim.win_set_cursor(win, {new_lines, 0})
        else
          return nil
        end
      end
      with_buf_wins(buf, _46_)
    end
    if (not a.get(opts, "suppress-hud?") and not visible_scrolling_log_3f) then
      display_hud()
    else
      close_hud()
    end
    return trim(buf)
  else
    return nil
  end
end
_2amodule_2a["append"] = append
local function create_win(cmd)
  state["last-open-cmd"] = cmd
  local buf = upsert_buf()
  local function _51_()
    if config["get-in"]({"log", "botright"}) then
      return "botright "
    else
      return ""
    end
  end
  nvim.command(("keepalt " .. _51_() .. cmd .. " " .. buffer.resolve(log_buf_name())))
  nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
  set_win_opts_21(0)
  return buffer.unlist(buf)
end
_2amodule_locals_2a["create-win"] = create_win
local function split()
  return create_win("split")
end
_2amodule_2a["split"] = split
local function vsplit()
  return create_win("vsplit")
end
_2amodule_2a["vsplit"] = vsplit
local function tab()
  return create_win("tabnew")
end
_2amodule_2a["tab"] = tab
local function buf()
  return create_win("buf")
end
_2amodule_2a["buf"] = buf
local function find_windows()
  local buf0 = upsert_buf()
  local function _52_(win)
    return ((state.hud.id ~= win) and (buf0 == nvim.win_get_buf(win)))
  end
  return a.filter(_52_, nvim.tabpage_list_wins(0))
end
_2amodule_locals_2a["find-windows"] = find_windows
local function close(windows)
  local function _53_(_241)
    return nvim.win_close(_241, true)
  end
  return a["run!"](_53_, windows)
end
_2amodule_locals_2a["close"] = close
local function close_visible()
  close_hud()
  return close(find_windows())
end
_2amodule_2a["close-visible"] = close_visible
local function toggle()
  local windows = find_windows()
  if a["empty?"](windows) then
    if ((state["last-open-cmd"] == "split") or (state["last-open-cmd"] == "vsplit")) then
      return create_win(state["last-open-cmd"])
    else
      return nil
    end
  else
    return close_visible(windows)
  end
end
_2amodule_2a["toggle"] = toggle
local function dbg(desc, ...)
  if config["get-in"]({"debug"}) then
    append(a.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](a["pr-str"](...))))
  else
  end
  return ...
end
_2amodule_2a["dbg"] = dbg
local function reset_soft()
  return on_new_log_buf(upsert_buf())
end
_2amodule_2a["reset-soft"] = reset_soft
local function reset_hard()
  return nvim.ex.bwipeout_(upsert_buf())
end
_2amodule_2a["reset-hard"] = reset_hard