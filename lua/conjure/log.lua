-- [nfnl] Compiled from fnl/conjure/log.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.log"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, buffer, client, config, editor, hook, nvim, str, text, timer, view, sponsors = autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.hook"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.aniseed.view"), require("conjure.sponsors")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["buffer"] = buffer
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["hook"] = hook
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["view"] = view
_2amodule_locals_2a["sponsors"] = sponsors
local append = (_2amodule_2a).append
local buf = (_2amodule_2a).buf
local clear_close_hud_passive_timer = (_2amodule_2a)["clear-close-hud-passive-timer"]
local close_hud = (_2amodule_2a)["close-hud"]
local close_hud_passive = (_2amodule_2a)["close-hud-passive"]
local close_visible = (_2amodule_2a)["close-visible"]
local cursor_scroll_position__3ecommand = (_2amodule_2a)["cursor-scroll-position->command"]
local dbg = (_2amodule_2a).dbg
local hud_lifetime_ms = (_2amodule_2a)["hud-lifetime-ms"]
local jump_to_latest = (_2amodule_2a)["jump-to-latest"]
local last_line = (_2amodule_2a)["last-line"]
local log_buf_3f = (_2amodule_2a)["log-buf?"]
local reset_hard = (_2amodule_2a)["reset-hard"]
local reset_soft = (_2amodule_2a)["reset-soft"]
local split = (_2amodule_2a).split
local tab = (_2amodule_2a).tab
local toggle = (_2amodule_2a).toggle
local vsplit = (_2amodule_2a).vsplit
local a0 = (_2amodule_locals_2a).a
local _break = (_2amodule_locals_2a)["break"]
local break_lines = (_2amodule_locals_2a)["break-lines"]
local buffer0 = (_2amodule_locals_2a).buffer
local client0 = (_2amodule_locals_2a).client
local close = (_2amodule_locals_2a).close
local config0 = (_2amodule_locals_2a).config
local create_win = (_2amodule_locals_2a)["create-win"]
local current_window_floating_3f = (_2amodule_locals_2a)["current-window-floating?"]
local display_hud = (_2amodule_locals_2a)["display-hud"]
local editor0 = (_2amodule_locals_2a).editor
local find_windows = (_2amodule_locals_2a)["find-windows"]
local flip_anchor = (_2amodule_locals_2a)["flip-anchor"]
local handle_low_priority_spam_21 = (_2amodule_locals_2a)["handle-low-priority-spam!"]
local hook0 = (_2amodule_locals_2a).hook
local hud_window_pos = (_2amodule_locals_2a)["hud-window-pos"]
local in_box_3f = (_2amodule_locals_2a)["in-box?"]
local log_buf_name = (_2amodule_locals_2a)["log-buf-name"]
local low_priority_streak_threshold = (_2amodule_locals_2a)["low-priority-streak-threshold"]
local nvim0 = (_2amodule_locals_2a).nvim
local on_new_log_buf = (_2amodule_locals_2a)["on-new-log-buf"]
local pad_box = (_2amodule_locals_2a)["pad-box"]
local set_win_opts_21 = (_2amodule_locals_2a)["set-win-opts!"]
local sponsors0 = (_2amodule_locals_2a).sponsors
local state = (_2amodule_locals_2a).state
local state_key_header = (_2amodule_locals_2a)["state-key-header"]
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
local timer0 = (_2amodule_locals_2a).timer
local trim = (_2amodule_locals_2a).trim
local upsert_buf = (_2amodule_locals_2a)["upsert-buf"]
local view0 = (_2amodule_locals_2a).view
local win_botline = (_2amodule_locals_2a)["win-botline"]
local win_visible_3f = (_2amodule_locals_2a)["win-visible?"]
local with_buf_wins = (_2amodule_locals_2a)["with-buf-wins"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local state0 = ((_2amodule_2a).state or {["last-open-cmd"] = "vsplit", hud = {id = nil, timer = nil, ["created-at-ms"] = 0, ["low-priority-spam"] = {streak = 0, ["help-displayed?"] = false}}, ["jump-to-latest"] = {mark = nil, ns = nvim0.create_namespace("conjure_log_jump_to_latest")}})
do end (_2amodule_locals_2a)["state"] = state0
do local _ = {nil, nil} end
local function _break0()
  return str0.join({client0.get("comment-prefix"), string.rep("-", config0["get-in"]({"log", "break_length"}))})
end
_2amodule_locals_2a["break"] = _break0
do local _ = {_break0, nil} end
local function state_key_header0()
  return str0.join({client0.get("comment-prefix"), "State: ", client0["state-key"]()})
end
_2amodule_locals_2a["state-key-header"] = state_key_header0
do local _ = {state_key_header0, nil} end
local function log_buf_name0()
  return str0.join({"conjure-log-", nvim0.fn.getpid(), client0.get("buf-suffix")})
end
_2amodule_locals_2a["log-buf-name"] = log_buf_name0
do local _ = {log_buf_name0, nil} end
local function log_buf_3f0(name)
  return text0["ends-with"](name, log_buf_name0())
end
_2amodule_2a["log-buf?"] = log_buf_3f
do local _ = {log_buf_3f, nil} end
local function on_new_log_buf(buf)
  state["jump-to-latest"].mark = nvim.buf_set_extmark(buf, state["jump-to-latest"].ns, 0, 0, {})
  if (vim.diagnostic and (false == config["get-in"]({"log", "diagnostics"}))) then
    if (1 == vim.fn.has("nvim-0.10")) then
      vim.diagnostic.enable(false, {bufnr = buf})
    else
      vim.diagnostic.disable(buf)
    end
  else
  end
  if (vim.treesitter and (false == config["get-in"]({"log", "treesitter"}))) then
    vim.treesitter.stop(buf)
    nvim.buf_set_option(buf, "syntax", "on")
  else
  end
  return nvim.buf_set_lines(buf, 0, -1, false, {str.join({client.get("comment-prefix"), "Sponsored by @", a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))), " \226\157\164"})})
end
_2amodule_locals_2a["on-new-log-buf"] = on_new_log_buf0
do local _ = {on_new_log_buf0, nil} end
local function upsert_buf0()
  return buffer0["upsert-hidden"](log_buf_name0(), client0.wrap(on_new_log_buf0))
end
_2amodule_locals_2a["upsert-buf"] = upsert_buf0
do local _ = {upsert_buf0, nil} end
local function clear_close_hud_passive_timer0()
  return a0["update-in"](state0, {"hud", "timer"}, timer0.destroy)
end
_2amodule_2a["clear-close-hud-passive-timer"] = clear_close_hud_passive_timer
local function _4_()
  if state.hud.id then
    pcall(nvim.win_close, state.hud.id, true)
    state.hud.id = nil
    return nil
  else
    return nil
  end
end
hook.define("close-hud", _4_)
local function close_hud()
  clear_close_hud_passive_timer()
  return hook.exec("close-hud")
end
_2amodule_2a["close-hud"] = close_hud0
do local _ = {close_hud0, nil} end
local function hud_lifetime_ms0()
  return (vim.loop.now() - state0.hud["created-at-ms"])
end
_2amodule_2a["hud-lifetime-ms"] = hud_lifetime_ms0
do local _ = {hud_lifetime_ms0, nil} end
local function close_hud_passive0()
  if (state0.hud.id and (hud_lifetime_ms0() > config0["get-in"]({"log", "hud", "minimum_lifetime_ms"}))) then
    local original_timer_id = state0.hud["timer-id"]
    local delay = config0["get-in"]({"log", "hud", "passive_close_delay"})
    if (0 == delay) then
      return close_hud0()
    else
      if not a0["get-in"](state0, {"hud", "timer"}) then
        return a0["assoc-in"](state0, {"hud", "timer"}, timer0.defer(close_hud0, delay))
      else
        return nil
      end
    end
  else
    return nil
  end
end
_2amodule_2a["close-hud-passive"] = close_hud_passive
do local _ = {close_hud_passive, nil} end
local function break_lines(buf)
  local break_str = _break()
  local function _11_(_9_)
    local _arg_10_ = _9_
    local n = _arg_10_[1]
    local s = _arg_10_[2]
    return (s == break_str)
  end
  return a.map(a.first, a.filter(_11_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
end
_2amodule_locals_2a["break-lines"] = break_lines
do local _ = {break_lines, nil} end
local function set_win_opts_21(win)
  local function _12_()
    if config["get-in"]({"log", "wrap"}) then
      return true
    else
      return false
    end
  end
  nvim.win_set_option(win, "wrap", _12_())
  nvim.win_set_option(win, "foldmethod", "marker")
  nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
  return nvim.win_set_option(win, "foldlevel", 0)
end
_2amodule_locals_2a["set-win-opts!"] = set_win_opts_210
do local _ = {set_win_opts_210, nil} end
local function in_box_3f0(box, pos)
  return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
end
_2amodule_locals_2a["in-box?"] = in_box_3f0
do local _ = {in_box_3f0, nil} end
local function flip_anchor0(anchor, n)
  local chars = {anchor:sub(1, 1), anchor:sub(2)}
  local flip = {N = "S", S = "N", E = "W", W = "E"}
  local function _13_(_241)
    return a.get(flip, _241)
  end
  return str.join(a.update(chars, n, _13_))
end
_2amodule_locals_2a["flip-anchor"] = flip_anchor
do local _ = {flip_anchor, nil} end
local function pad_box(box, padding)
  local function _14_(_241)
    return (_241 - padding.x)
  end
  local function _15_(_241)
    return (_241 - padding.y)
  end
  local function _16_(_241)
    return (_241 + padding.x)
  end
  local function _17_(_241)
    return (_241 + padding.y)
  end
  return a.update(a.update(a.update(a.update(box, "x1", _14_), "y1", _15_), "x2", _16_), "y2", _17_)
end
_2amodule_locals_2a["pad-box"] = pad_box0
do local _ = {pad_box0, nil} end
local function hud_window_pos0(anchor, size, rec_3f)
  local north = 0
  local west = 0
  local south = (editor0.height() - 2)
  local east = editor0.width()
  local padding_percent = config0["get-in"]({"log", "hud", "overlap_padding"})
  local pos
  local _18_
  if ("NE" == anchor) then
    _18_ = {row = north, col = east, box = {y1 = north, x1 = (east - size.width), y2 = (north + size.height), x2 = east}}
  elseif ("SE" == anchor) then
    _18_ = {row = south, col = east, box = {y1 = (south - size.height), x1 = (east - size.width), y2 = south, x2 = east}}
  elseif ("SW" == anchor) then
    _18_ = {row = south, col = west, box = {y1 = (south - size.height), x1 = west, y2 = south, x2 = (west + size.width)}}
  elseif ("NW" == anchor) then
    _18_ = {row = north, col = west, box = {y1 = north, x1 = west, y2 = (north + size.height), x2 = (west + size.width)}}
  else
    nvim.err_writeln("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
    _18_ = hud_window_pos("NE", size)
  end
  pos = a.assoc(_18_, "anchor", anchor)
  if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
    local function _20_()
      if (size.width > size.height) then
        return 1
      else
        return 2
      end
    end
    return hud_window_pos(flip_anchor(anchor, _20_()), size, true)
  else
    return pos
  end
end
_2amodule_locals_2a["hud-window-pos"] = hud_window_pos0
do local _ = {hud_window_pos0, nil} end
local function current_window_floating_3f0()
  return ("number" == type(a0.get(nvim0.win_get_config(0), "zindex")))
end
_2amodule_locals_2a["current-window-floating?"] = current_window_floating_3f0
do local _ = {current_window_floating_3f0, nil} end
local low_priority_streak_threshold0 = 5
_2amodule_locals_2a["low-priority-streak-threshold"] = low_priority_streak_threshold0
do local _ = {nil, nil} end
local function handle_low_priority_spam_210(low_priority_3f)
  if not a0["get-in"](state0, {"hud", "low-priority-spam", "help-displayed?"}) then
    if low_priority_3f then
      a0["update-in"](state0, {"hud", "low-priority-spam", "streak"}, a0.inc)
    else
      a0["assoc-in"](state0, {"hud", "low-priority-spam", "streak"}, 0)
    end
    if (a0["get-in"](state0, {"hud", "low-priority-spam", "streak"}) > low_priority_streak_threshold0) then
      do
        local pref = client0.get("comment-prefix")
        client0.schedule((_2amodule_2a).append, {(pref .. "Is the HUD popping up too much and annoying you in this project?"), (pref .. "Set this option to suppress this kind of output for this session."), (pref .. "  :let g:conjure#log#hud#ignore_low_priority = v:true")}, {["break?"] = true})
      end
      return a0["assoc-in"](state0, {"hud", "low-priority-spam", "help-displayed?"}, true)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_locals_2a["handle-low-priority-spam!"] = handle_low_priority_spam_21
local function _25_(opts)
  local buf = upsert_buf()
  local last_break = a.last(break_lines(buf))
  local line_count = nvim.buf_line_count(buf)
  local size = {width = editor["percent-width"](config["get-in"]({"log", "hud", "width"})), height = editor["percent-height"](config["get-in"]({"log", "hud", "height"}))}
  local pos = hud_window_pos(config["get-in"]({"log", "hud", "anchor"}), size)
  local border = config["get-in"]({"log", "hud", "border"})
  local win_opts = a.merge({relative = "editor", row = pos.row, col = pos.col, anchor = pos.anchor, width = size.width, height = size.height, style = "minimal", zindex = config["get-in"]({"log", "hud", "zindex"}), border = border, focusable = false})
  if (state.hud.id and not nvim.win_is_valid(state.hud.id)) then
    close_hud()
  else
  end
  if state0.hud.id then
    nvim0.win_set_buf(state0.hud.id, buf0)
  else
    handle_low_priority_spam_210(a0.get(opts, "low-priority?"))
    state0.hud.id = nvim0.open_win(buf0, false, win_opts)
    set_win_opts_210(state0.hud.id)
  end
  state0.hud["created-at-ms"] = vim.loop.now()
  if last_break then
    nvim0.win_set_cursor(state0.hud.id, {1, 0})
    return nvim0.win_set_cursor(state0.hud.id, {math.min((last_break + a0.inc(math.floor((win_opts.height / 2)))), line_count), 0})
  else
    return nvim0.win_set_cursor(state0.hud.id, {line_count, 0})
  end
end
hook.define("display-hud", _25_)
local function display_hud(opts)
  if (config["get-in"]({"log", "hud", "enabled"}) and not current_window_floating_3f() and (not config["get-in"]({"log", "hud", "ignore_low_priority"}) or (config["get-in"]({"log", "hud", "ignore_low_priority"}) and not a.get(opts, "low-priority?")))) then
    clear_close_hud_passive_timer()
    return hook.exec("display-hud", opts)
  else
    return nil
  end
end
_2amodule_locals_2a["display-hud"] = display_hud0
do local _ = {display_hud0, nil} end
local function win_visible_3f0(win)
  return (nvim0.fn.tabpagenr() == a0.first(nvim0.fn.win_id2tabwin(win)))
end
_2amodule_locals_2a["win-visible?"] = win_visible_3f
do local _ = {win_visible_3f, nil} end
local function with_buf_wins(buf, f)
  local function _30_(win)
    if (buf == nvim.win_get_buf(win)) then
      return f(win)
    else
      return nil
    end
  end
  return a["run!"](_30_, nvim.list_wins())
end
_2amodule_locals_2a["with-buf-wins"] = with_buf_wins0
do local _ = {with_buf_wins0, nil} end
local function win_botline0(win)
  return a0.get(a0.first(nvim0.fn.getwininfo(win)), "botline")
end
_2amodule_locals_2a["win-botline"] = win_botline0
do local _ = {win_botline0, nil} end
local function trim0(buf0)
  local line_count = nvim0.buf_line_count(buf0)
  if (line_count > config0["get-in"]({"log", "trim", "at"})) then
    local target_line_count = (line_count - config0["get-in"]({"log", "trim", "to"}))
    local break_line
    local function _32_(line)
      if (line >= target_line_count) then
        return line
      else
        return nil
      end
    end
    break_line = a.some(_32_, break_lines(buf))
    if break_line then
      nvim.buf_set_lines(buf, 0, break_line, false, {})
      local line_count0 = nvim.buf_line_count(buf)
      local function _34_(win)
        local _let_35_ = nvim.win_get_cursor(win)
        local row = _let_35_[1]
        local col = _let_35_[2]
        nvim.win_set_cursor(win, {1, 0})
        return nvim.win_set_cursor(win, {row, col})
      end
      return with_buf_wins(buf, _34_)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_locals_2a["trim"] = trim0
do local _ = {trim0, nil} end
local function last_line0(buf0, extra_offset)
  return a0.first(nvim0.buf_get_lines((buf0 or upsert_buf0()), (-2 + (extra_offset or 0)), -1, false))
end
_2amodule_2a["last-line"] = last_line0
do local _ = {last_line0, nil} end
local cursor_scroll_position__3ecommand0 = {top = "normal zt", center = "normal zz", bottom = "normal zb", none = nil}
_2amodule_2a["cursor-scroll-position->command"] = cursor_scroll_position__3ecommand0
do local _ = {nil, nil} end
local function jump_to_latest()
  local buf = upsert_buf()
  local last_eval_start = nvim.buf_get_extmark_by_id(buf, state["jump-to-latest"].ns, state["jump-to-latest"].mark, {})
  local function _38_(win)
    local function _39_()
      return nvim.win_set_cursor(win, last_eval_start)
    end
    pcall(_39_)
    local cmd = a.get(cursor_scroll_position__3ecommand, config["get-in"]({"log", "jump_to_latest", "cursor_scroll_position"}))
    if cmd then
      local function _40_()
        return nvim.command(cmd)
      end
      return nvim.win_call(win, _40_)
    else
      return nil
    end
  end
  return with_buf_wins(buf, _38_)
end
_2amodule_2a["jump-to-latest"] = jump_to_latest0
do local _ = {jump_to_latest0, nil} end
local function append0(lines, opts)
  local line_count = a0.count(lines)
  if (line_count > 0) then
    local visible_scrolling_log_3f = false
    local buf0 = upsert_buf0()
    local join_first_3f = a0.get(opts, "join-first?")
    local lines0
    local function _42_(line)
      return string.gsub(tostring(line), "\n", "\226\134\181")
    end
    lines0 = a.map(_42_, lines)
    local lines1
    if (line_count <= config0["get-in"]({"log", "strip_ansi_escape_sequences_line_limit"})) then
      lines1 = a0.map(text0["strip-ansi-escape-sequences"], lines0)
    else
      lines1 = lines0
    end
    local comment_prefix = client0.get("comment-prefix")
    local fold_marker_end = str0.join({comment_prefix, config0["get-in"]({"log", "fold", "marker", "end"})})
    local lines2
    if (not a0.get(opts, "break?") and not join_first_3f and config0["get-in"]({"log", "fold", "enabled"}) and (a0.count(lines1) >= config0["get-in"]({"log", "fold", "lines"}))) then
      lines2 = a0.concat({str0.join({comment_prefix, config0["get-in"]({"log", "fold", "marker", "start"}), " ", text0["left-sample"](str0.join("\n", lines1), editor0["percent-width"](config0["get-in"]({"preview", "sample_limit"})))})}, lines1, {fold_marker_end})
    else
      lines2 = lines1
    end
    local last_fold_3f = (fold_marker_end == last_line0(buf0))
    local lines3
    if a.get(opts, "break?") then
      local _45_
      if client["multiple-states?"]() then
        _45_ = {state_key_header()}
      else
        _45_ = nil
      end
      lines3 = a.concat({_break()}, _45_, lines2)
    elseif join_first_3f then
      local _47_
      if last_fold_3f then
        _47_ = {(last_line(buf, -1) .. a.first(lines2)), fold_marker_end}
      else
        _47_ = {(last_line(buf) .. a.first(lines2))}
      end
      lines3 = a.concat(_47_, a.rest(lines2))
    else
      lines3 = lines2
    end
    local old_lines = nvim0.buf_line_count(buf0)
    do
      local ok_3f, err = nil, nil
      local function _50_()
        local _51_
        if buffer["empty?"](buf) then
          _51_ = 0
        elseif join_first_3f then
          if last_fold_3f then
            _51_ = -3
          else
            _51_ = -2
          end
        else
          _51_ = -1
        end
        return nvim.buf_set_lines(buf, _51_, -1, false, lines3)
      end
      ok_3f, err = pcall(_50_)
      if not ok_3f then
        error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a0["pr-str"](lines3)))
      else
      end
    end
    do
      local new_lines = nvim.buf_line_count(buf)
      local jump_to_latest_3f = config["get-in"]({"log", "jump_to_latest", "enabled"})
      local _55_
      if join_first_3f then
        _55_ = old_lines
      else
        _55_ = a.inc(old_lines)
      end
      nvim.buf_set_extmark(buf, state["jump-to-latest"].ns, _55_, 0, {id = state["jump-to-latest"].mark})
      local function _57_(win)
        visible_scrolling_log_3f = ((win ~= state.hud.id) and win_visible_3f(win) and (jump_to_latest_3f or (win_botline(win) >= old_lines)))
        local _let_58_ = nvim.win_get_cursor(win)
        local row = _let_58_[1]
        local _ = _let_58_[2]
        if jump_to_latest_3f then
          return jump_to_latest0()
        elseif (row == old_lines) then
          return nvim0.win_set_cursor(win, {new_lines, 0})
        else
          return nil
        end
      end
      with_buf_wins(buf, _57_)
    end
    if (not a0.get(opts, "suppress-hud?") and not visible_scrolling_log_3f) then
      display_hud0(opts)
    else
      close_hud0()
    end
    return trim0(buf0)
  else
    return nil
  end
end
_2amodule_2a["append"] = append
do local _ = {append, nil} end
local function create_win(cmd)
  state["last-open-cmd"] = cmd
  local buf = upsert_buf()
  local function _62_()
    if config["get-in"]({"log", "botright"}) then
      return "botright "
    else
      return ""
    end
  end
  nvim.command(("keepalt " .. _62_() .. cmd .. " " .. buffer.resolve(log_buf_name())))
  nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
  set_win_opts_21(0)
  return buffer.unlist(buf)
end
_2amodule_locals_2a["create-win"] = create_win0
do local _ = {create_win0, nil} end
local function split0()
  return create_win0("split")
end
_2amodule_2a["split"] = split0
do local _ = {split0, nil} end
local function vsplit0()
  return create_win0("vsplit")
end
_2amodule_2a["vsplit"] = vsplit0
do local _ = {vsplit0, nil} end
local function tab0()
  return create_win0("tabnew")
end
_2amodule_2a["tab"] = tab0
do local _ = {tab0, nil} end
local function buf0()
  return create_win0("buf")
end
_2amodule_2a["buf"] = buf
do local _ = {buf, nil} end
local function find_windows()
  local buf0 = upsert_buf()
  local function _63_(win)
    return ((state.hud.id ~= win) and (buf0 == nvim.win_get_buf(win)))
  end
  return a.filter(_63_, nvim.tabpage_list_wins(0))
end
_2amodule_locals_2a["find-windows"] = find_windows
do local _ = {find_windows, nil} end
local function close(windows)
  local function _64_(_241)
    return nvim.win_close(_241, true)
  end
  return a["run!"](_64_, windows)
end
_2amodule_locals_2a["close"] = close0
do local _ = {close0, nil} end
local function close_visible0()
  close_hud0()
  return close0(find_windows0())
end
_2amodule_2a["close-visible"] = close_visible0
do local _ = {close_visible0, nil} end
local function toggle0()
  local windows = find_windows0()
  if a0["empty?"](windows) then
    if ((state0["last-open-cmd"] == "split") or (state0["last-open-cmd"] == "vsplit")) then
      return create_win0(state0["last-open-cmd"])
    else
      return nil
    end
  else
    return close_visible0(windows)
  end
end
_2amodule_2a["toggle"] = toggle0
do local _ = {toggle0, nil} end
local function dbg0(desc, ...)
  if config0["get-in"]({"debug"}) then
    append0(a0.concat({(client0.get("comment-prefix") .. "debug: " .. desc)}, text0["split-lines"](a0["pr-str"](...))))
  else
  end
  return ...
end
_2amodule_2a["dbg"] = dbg0
do local _ = {dbg0, nil} end
local function reset_soft0()
  return on_new_log_buf0(upsert_buf0())
end
_2amodule_2a["reset-soft"] = reset_soft0
do local _ = {reset_soft0, nil} end
local function reset_hard0()
  return nvim0.ex.bwipeout_(upsert_buf0())
end
_2amodule_2a["reset-hard"] = reset_hard0
do local _ = {reset_hard0, nil} end
return _2amodule_2a
