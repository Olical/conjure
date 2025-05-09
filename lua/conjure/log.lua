-- [nfnl] fnl/conjure/log.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local buffer = autoload("conjure.buffer")
local client = autoload("conjure.client")
local hook = autoload("conjure.hook")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local editor = autoload("conjure.editor")
local timer = autoload("conjure.timer")
local sponsors = require("conjure.sponsors")
local state = {["last-open-cmd"] = "vsplit", hud = {id = nil, timer = nil, ["created-at-ms"] = 0, ["low-priority-spam"] = {streak = 0, ["help-displayed?"] = false}}, ["jump-to-latest"] = {mark = nil, ns = vim.api.nvim_create_namespace("conjure_log_jump_to_latest")}}
local function _break()
  return str.join({client.get("comment-prefix"), string.rep("-", config["get-in"]({"log", "break_length"}))})
end
local function state_key_header()
  return str.join({client.get("comment-prefix"), "State: ", client["state-key"]()})
end
local function log_buf_name()
  return str.join({"conjure-log-", vim.fn.getpid(), client.get("buf-suffix")})
end
local function log_buf_3f(name)
  return vim.endswith(name, log_buf_name())
end
local function on_new_log_buf(buf)
  state["jump-to-latest"].mark = vim.api.nvim_buf_set_extmark(buf, state["jump-to-latest"].ns, 0, 0, {})
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
    vim.bo[buf]["syntax"] = "on"
  else
  end
  return vim.api.nvim_buf_set_lines(buf, 0, -1, false, {str.join({client.get("comment-prefix"), "Sponsored by @", core.get(sponsors, core.inc(math.floor(core.rand(core.dec(core.count(sponsors)))))), " \226\157\164"})})
end
local function upsert_buf()
  return buffer["upsert-hidden"](log_buf_name(), client.wrap(on_new_log_buf))
end
local function clear_close_hud_passive_timer()
  return core["update-in"](state, {"hud", "timer"}, timer.destroy)
end
local function _5_()
  if state.hud.id then
    pcall(vim.api.nvim_win_close, state.hud.id, true)
    state.hud.id = nil
    return nil
  else
    return nil
  end
end
hook.define("close-hud", _5_)
local function close_hud()
  clear_close_hud_passive_timer()
  return hook.exec("close-hud")
end
local function hud_lifetime_ms()
  return (vim.loop.now() - state.hud["created-at-ms"])
end
local function close_hud_passive()
  if (state.hud.id and (hud_lifetime_ms() > config["get-in"]({"log", "hud", "minimum_lifetime_ms"}))) then
    local delay = config["get-in"]({"log", "hud", "passive_close_delay"})
    if (0 == delay) then
      return close_hud()
    else
      if not core["get-in"](state, {"hud", "timer"}) then
        return core["assoc-in"](state, {"hud", "timer"}, timer.defer(close_hud, delay))
      else
        return nil
      end
    end
  else
    return nil
  end
end
local function break_lines(buf)
  local break_str = _break()
  local function _11_(_10_)
    local _n = _10_[1]
    local s = _10_[2]
    return (s == break_str)
  end
  return core.map(core.first, core.filter(_11_, core["kv-pairs"](vim.api.nvim_buf_get_lines(buf, 0, -1, false))))
end
local function set_win_opts_21(win)
  local _12_
  if config["get-in"]({"log", "wrap"}) then
    _12_ = true
  else
    _12_ = false
  end
  vim.wo[win]["wrap"] = _12_
  vim.wo[win]["foldmethod"] = "marker"
  vim.wo[win]["foldmarker"] = (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"}))
  vim.wo[win]["foldlevel"] = 0
  return nil
end
local function in_box_3f(box, pos)
  return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
end
local function flip_anchor(anchor, n)
  local chars = {anchor:sub(1, 1), anchor:sub(2)}
  local flip = {N = "S", S = "N", E = "W", W = "E"}
  local function _14_(_241)
    return core.get(flip, _241)
  end
  return str.join(core.update(chars, n, _14_))
end
local function pad_box(box, padding)
  local function _15_(_241)
    return (_241 - padding.x)
  end
  local function _16_(_241)
    return (_241 - padding.y)
  end
  local function _17_(_241)
    return (_241 + padding.x)
  end
  local function _18_(_241)
    return (_241 + padding.y)
  end
  return core.update(core.update(core.update(core.update(box, "x1", _15_), "y1", _16_), "x2", _17_), "y2", _18_)
end
local function hud_window_pos(anchor, size, rec_3f)
  local north = 0
  local west = 0
  local south = (editor.height() - 2)
  local east = editor.width()
  local padding_percent = config["get-in"]({"log", "hud", "overlap_padding"})
  local pos
  local _19_
  if ("NE" == anchor) then
    _19_ = {row = north, col = east, box = {y1 = north, x1 = (east - size.width), y2 = (north + size.height), x2 = east}}
  elseif ("SE" == anchor) then
    _19_ = {row = south, col = east, box = {y1 = (south - size.height), x1 = (east - size.width), y2 = south, x2 = east}}
  elseif ("SW" == anchor) then
    _19_ = {row = south, col = west, box = {y1 = (south - size.height), x1 = west, y2 = south, x2 = (west + size.width)}}
  elseif ("NW" == anchor) then
    _19_ = {row = north, col = west, box = {y1 = north, x1 = west, y2 = (north + size.height), x2 = (west + size.width)}}
  else
    vim.notify("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW", vim.log.levels.ERROR)
    _19_ = hud_window_pos("NE", size)
  end
  pos = core.assoc(_19_, "anchor", anchor)
  if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
    local function _21_()
      if (size.width > size.height) then
        return 1
      else
        return 2
      end
    end
    return hud_window_pos(flip_anchor(anchor, _21_()), size, true)
  else
    return pos
  end
end
local function current_window_floating_3f()
  return ("number" == type(core.get(vim.api.nvim_win_get_config(0), "zindex")))
end
local low_priority_streak_threshold = 5
local function handle_low_priority_spam_21(low_priority_3f)
  if not core["get-in"](state, {"hud", "low-priority-spam", "help-displayed?"}) then
    if low_priority_3f then
      core["update-in"](state, {"hud", "low-priority-spam", "streak"}, core.inc)
    else
      core["assoc-in"](state, {"hud", "low-priority-spam", "streak"}, 0)
    end
    if (core["get-in"](state, {"hud", "low-priority-spam", "streak"}) > low_priority_streak_threshold) then
      do
        local pref = client.get("comment-prefix")
        client.schedule(require("conjure.log").append, {(pref .. "Is the HUD popping up too much and annoying you in this project?"), (pref .. "Set this option to suppress this kind of output for this session."), (pref .. "  :let g:conjure#log#hud#ignore_low_priority = v:true")}, {["break?"] = true})
      end
      return core["assoc-in"](state, {"hud", "low-priority-spam", "help-displayed?"}, true)
    else
      return nil
    end
  else
    return nil
  end
end
local function _26_(opts)
  local buf = upsert_buf()
  local last_break = core.last(break_lines(buf))
  local line_count = vim.api.nvim_buf_line_count(buf)
  local size = {width = editor["percent-width"](config["get-in"]({"log", "hud", "width"})), height = editor["percent-height"](config["get-in"]({"log", "hud", "height"}))}
  local pos = hud_window_pos(config["get-in"]({"log", "hud", "anchor"}), size)
  local border = config["get-in"]({"log", "hud", "border"})
  local win_opts = core.merge({relative = "editor", row = pos.row, col = pos.col, anchor = pos.anchor, width = size.width, height = size.height, style = "minimal", zindex = config["get-in"]({"log", "hud", "zindex"}), border = border, focusable = false})
  if (state.hud.id and not vim.api.nvim_win_is_valid(state.hud.id)) then
    close_hud()
  else
  end
  if state.hud.id then
    vim.api.nvim_win_set_buf(state.hud.id, buf)
  else
    handle_low_priority_spam_21(core.get(opts, "low-priority?"))
    state.hud.id = vim.api.nvim_open_win(buf, false, win_opts)
    set_win_opts_21(state.hud.id)
  end
  state.hud["created-at-ms"] = vim.loop.now()
  if last_break then
    vim.api.nvim_win_set_cursor(state.hud.id, {1, 0})
    return vim.api.nvim_win_set_cursor(state.hud.id, {math.min((last_break + core.inc(math.floor((win_opts.height / 2)))), line_count), 0})
  else
    return vim.api.nvim_win_set_cursor(state.hud.id, {line_count, 0})
  end
end
hook.define("display-hud", _26_)
local function display_hud(opts)
  if (config["get-in"]({"log", "hud", "enabled"}) and not current_window_floating_3f() and (not config["get-in"]({"log", "hud", "ignore_low_priority"}) or (config["get-in"]({"log", "hud", "ignore_low_priority"}) and not core.get(opts, "low-priority?")))) then
    clear_close_hud_passive_timer()
    return hook.exec("display-hud", opts)
  else
    return nil
  end
end
local function win_visible_3f(win)
  return (vim.fn.tabpagenr() == core.first(vim.fn.win_id2tabwin(win)))
end
local function with_buf_wins(buf, f)
  local function _31_(win)
    if (buf == vim.api.nvim_win_get_buf(win)) then
      return f(win)
    else
      return nil
    end
  end
  return core["run!"](_31_, vim.api.nvim_list_wins())
end
local function win_botline(win)
  return core.get(core.first(vim.fn.getwininfo(win)), "botline")
end
local function trim(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)
  if (line_count > config["get-in"]({"log", "trim", "at"})) then
    local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
    local break_line
    local function _33_(line)
      if (line >= target_line_count) then
        return line
      else
        return nil
      end
    end
    break_line = core.some(_33_, break_lines(buf))
    if break_line then
      vim.api.nvim_buf_set_lines(buf, 0, break_line, false, {})
      local line_count0 = vim.api.nvim_buf_line_count(buf)
      local function _35_(win)
        local _let_36_ = vim.api.nvim_win_get_cursor(win)
        local row = _let_36_[1]
        local col = _let_36_[2]
        vim.api.nvim_win_set_cursor(win, {1, 0})
        return vim.api.nvim_win_set_cursor(win, {row, col})
      end
      return with_buf_wins(buf, _35_)
    else
      return nil
    end
  else
    return nil
  end
end
local function last_line(buf, extra_offset)
  return core.first(vim.api.nvim_buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
end
local cursor_scroll_position__3ecommand = {top = "normal zt", center = "normal zz", bottom = "normal zb", none = nil}
local function jump_to_latest()
  local buf = upsert_buf()
  local last_eval_start = vim.api.nvim_buf_get_extmark_by_id(buf, state["jump-to-latest"].ns, state["jump-to-latest"].mark, {})
  local function _39_(win)
    local function _40_()
      return vim.api.nvim_win_set_cursor(win, last_eval_start)
    end
    pcall(_40_)
    local cmd = core.get(cursor_scroll_position__3ecommand, config["get-in"]({"log", "jump_to_latest", "cursor_scroll_position"}))
    if cmd then
      local function _41_()
        return vim.cmd(cmd)
      end
      return vim.api.nvim_win_call(win, _41_)
    else
      return nil
    end
  end
  return with_buf_wins(buf, _39_)
end
local function append(lines, opts)
  local line_count = core.count(lines)
  if (line_count > 0) then
    local visible_scrolling_log_3f = false
    local visible_log_3f = false
    local buf = upsert_buf()
    local join_first_3f = core.get(opts, "join-first?")
    local lines0
    local function _43_(line)
      return string.gsub(tostring(line), "\n", "\226\134\181")
    end
    lines0 = core.map(_43_, lines)
    local lines1
    if (line_count <= config["get-in"]({"log", "strip_ansi_escape_sequences_line_limit"})) then
      lines1 = core.map(text["strip-ansi-escape-sequences"], lines0)
    else
      lines1 = lines0
    end
    local comment_prefix = client.get("comment-prefix")
    local fold_marker_end = str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "end"})})
    local lines2
    if (not core.get(opts, "break?") and not join_first_3f and config["get-in"]({"log", "fold", "enabled"}) and (core.count(lines1) >= config["get-in"]({"log", "fold", "lines"}))) then
      lines2 = core.concat({str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "start"}), " ", text["left-sample"](str.join("\n", lines1), editor["percent-width"](config["get-in"]({"preview", "sample_limit"})))})}, lines1, {fold_marker_end})
    else
      lines2 = lines1
    end
    local last_fold_3f = (fold_marker_end == last_line(buf))
    local lines3
    if core.get(opts, "break?") then
      local _46_
      if client["multiple-states?"]() then
        _46_ = {state_key_header()}
      else
        _46_ = nil
      end
      lines3 = core.concat({_break()}, _46_, lines2)
    elseif join_first_3f then
      local _48_
      if last_fold_3f then
        _48_ = {(last_line(buf, -1) .. core.first(lines2)), fold_marker_end}
      else
        _48_ = {(last_line(buf) .. core.first(lines2))}
      end
      lines3 = core.concat(_48_, core.rest(lines2))
    else
      lines3 = lines2
    end
    local old_lines = vim.api.nvim_buf_line_count(buf)
    do
      local ok_3f, err = nil, nil
      local function _51_()
        local _52_
        if buffer["empty?"](buf) then
          _52_ = 0
        elseif join_first_3f then
          if last_fold_3f then
            _52_ = -3
          else
            _52_ = -2
          end
        else
          _52_ = -1
        end
        return vim.api.nvim_buf_set_lines(buf, _52_, -1, false, lines3)
      end
      ok_3f, err = pcall(_51_)
      if not ok_3f then
        error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. core["pr-str"](lines3)))
      else
      end
    end
    do
      local new_lines = vim.api.nvim_buf_line_count(buf)
      local jump_to_latest_3f = config["get-in"]({"log", "jump_to_latest", "enabled"})
      local _56_
      if join_first_3f then
        _56_ = old_lines
      else
        _56_ = core.inc(old_lines)
      end
      vim.api.nvim_buf_set_extmark(buf, state["jump-to-latest"].ns, _56_, 0, {id = state["jump-to-latest"].mark})
      local function _58_(win)
        visible_scrolling_log_3f = ((win ~= state.hud.id) and win_visible_3f(win) and (jump_to_latest_3f or (win_botline(win) >= old_lines)))
        visible_log_3f = ((win ~= state.hud.id) and win_visible_3f(win))
        local _let_59_ = vim.api.nvim_win_get_cursor(win)
        local row = _let_59_[1]
        local _ = _let_59_[2]
        if jump_to_latest_3f then
          return jump_to_latest()
        elseif (row == old_lines) then
          return vim.api.nvim_win_set_cursor(win, {new_lines, 0})
        else
          return nil
        end
      end
      with_buf_wins(buf, _58_)
    end
    local open_when = config["get-in"]({"log", "hud", "open_when"})
    if (not core.get(opts, "suppress-hud?") and ((("last-log-line-not-visible" == open_when) and not visible_scrolling_log_3f) or (("log-win-not-visible" == open_when) and not visible_log_3f))) then
      return display_hud(opts)
    else
      return trim(buf)
    end
  else
    return nil
  end
end
local function create_win(cmd)
  state["last-open-cmd"] = cmd
  local buf = upsert_buf()
  local _63_
  if config["get-in"]({"log", "botright"}) then
    _63_ = "botright"
  else
    _63_ = ""
  end
  vim.cmd(string.format("keepalt %s %s %s", _63_, cmd, buffer.resolve(log_buf_name())))
  vim.api.nvim_win_set_cursor(0, {vim.api.nvim_buf_line_count(buf), 0})
  set_win_opts_21(0)
  return buffer.unlist(buf)
end
local function split()
  create_win("split")
  local height = config["get-in"]({"log", "split", "height"})
  if height then
    return vim.api.nvim_win_set_height(0, editor["percent-height"](height))
  else
    return nil
  end
end
local function vsplit()
  create_win("vsplit")
  local width = config["get-in"]({"log", "split", "width"})
  if width then
    return vim.api.nvim_win_set_width(0, editor["percent-width"](width))
  else
    return nil
  end
end
local function tab()
  return create_win("tabnew")
end
local function buf()
  return create_win("buf")
end
local function find_windows()
  local buf0 = upsert_buf()
  local function _67_(win)
    return ((state.hud.id ~= win) and (buf0 == vim.api.nvim_win_get_buf(win)))
  end
  return core.filter(_67_, vim.api.nvim_tabpage_list_wins(0))
end
local function close(windows)
  local function _68_(_241)
    return vim.api.nvim_win_close(_241, true)
  end
  return core["run!"](_68_, windows)
end
local function close_visible()
  close_hud()
  return close(find_windows())
end
local function toggle()
  local windows = find_windows()
  if core["empty?"](windows) then
    if ((state["last-open-cmd"] == "split") or (state["last-open-cmd"] == "vsplit")) then
      return create_win(state["last-open-cmd"])
    else
      return nil
    end
  else
    return close_visible(windows)
  end
end
local function dbg(desc, ...)
  if config["get-in"]({"debug"}) then
    append(core.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](core["pr-str"](...))))
  else
  end
  return ...
end
local function reset_soft()
  return on_new_log_buf(upsert_buf())
end
local function reset_hard()
  return vim.api.nvim_buf_delete(upsert_buf(), {force = true})
end
return {["log-buf?"] = log_buf_3f, ["clear-close-hud-passive-timer"] = clear_close_hud_passive_timer, ["close-hud"] = close_hud, ["hud-lifetime-ms"] = hud_lifetime_ms, ["close-hud-passive"] = close_hud_passive, ["last-line"] = last_line, ["cursor-scroll-position->command"] = cursor_scroll_position__3ecommand, ["jump-to-latest"] = jump_to_latest, append = append, split = split, vsplit = vsplit, tab = tab, buf = buf, ["close-visible"] = close_visible, toggle = toggle, dbg = dbg, ["reset-soft"] = reset_soft, ["reset-hard"] = reset_hard}
