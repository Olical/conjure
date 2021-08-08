local _2afile_2a = "fnl/conjure/log.fnl"
local _1_
do
  local name_4_auto = "conjure.log"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.aniseed.view"), require("conjure.sponsors")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", timer = "conjure.timer", view = "conjure.aniseed.view"}, require = {sponsors = "conjure.sponsors"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local view = _local_4_[10]
local sponsors = _local_4_[11]
local buffer = _local_4_[2]
local client = _local_4_[3]
local config = _local_4_[4]
local editor = _local_4_[5]
local nvim = _local_4_[6]
local str = _local_4_[7]
local text = _local_4_[8]
local timer = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.log"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local state
do
  local v_23_auto = ((_1_)["aniseed/locals"].state or {hud = {id = nil, timer = nil}})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local _break
do
  local v_23_auto
  local function _break0()
    return (client.get("comment-prefix") .. string.rep("-", config["get-in"]({"log", "break_length"})))
  end
  v_23_auto = _break0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["break"] = v_23_auto
  _break = v_23_auto
end
local state_key_header
do
  local v_23_auto
  local function state_key_header0()
    return (client.get("comment-prefix") .. "State: " .. client["state-key"]())
  end
  v_23_auto = state_key_header0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state-key-header"] = v_23_auto
  state_key_header = v_23_auto
end
local log_buf_name
do
  local v_23_auto
  local function log_buf_name0()
    return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
  end
  v_23_auto = log_buf_name0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["log-buf-name"] = v_23_auto
  log_buf_name = v_23_auto
end
local log_buf_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function log_buf_3f0(name)
      return name:match((log_buf_name() .. "$"))
    end
    v_25_auto = log_buf_3f0
    _1_["log-buf?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["log-buf?"] = v_23_auto
  log_buf_3f = v_23_auto
end
local on_new_log_buf
do
  local v_23_auto
  local function on_new_log_buf0(buf)
    return nvim.buf_set_lines(buf, 0, -1, false, {(client.get("comment-prefix") .. "Sponsored by @" .. a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))) .. " \226\157\164")})
  end
  v_23_auto = on_new_log_buf0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-new-log-buf"] = v_23_auto
  on_new_log_buf = v_23_auto
end
local upsert_buf
do
  local v_23_auto
  local function upsert_buf0()
    return buffer["upsert-hidden"](log_buf_name(), on_new_log_buf)
  end
  v_23_auto = upsert_buf0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["upsert-buf"] = v_23_auto
  upsert_buf = v_23_auto
end
local clear_close_hud_passive_timer
do
  local v_23_auto
  do
    local v_25_auto
    local function clear_close_hud_passive_timer0()
      return a["update-in"](state, {"hud", "timer"}, timer.destroy)
    end
    v_25_auto = clear_close_hud_passive_timer0
    _1_["clear-close-hud-passive-timer"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clear-close-hud-passive-timer"] = v_23_auto
  clear_close_hud_passive_timer = v_23_auto
end
local close_hud
do
  local v_23_auto
  do
    local v_25_auto
    local function close_hud0()
      clear_close_hud_passive_timer()
      if state.hud.id then
        pcall(nvim.win_close, state.hud.id, true)
        state.hud.id = nil
        return nil
      end
    end
    v_25_auto = close_hud0
    _1_["close-hud"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-hud"] = v_23_auto
  close_hud = v_23_auto
end
local close_hud_passive
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = close_hud_passive0
    _1_["close-hud-passive"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-hud-passive"] = v_23_auto
  close_hud_passive = v_23_auto
end
local break_lines
do
  local v_23_auto
  local function break_lines0(buf)
    local break_str = _break()
    local function _14_(_12_)
      local _arg_13_ = _12_
      local n = _arg_13_[1]
      local s = _arg_13_[2]
      return (s == break_str)
    end
    return a.map(a.first, a.filter(_14_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
  end
  v_23_auto = break_lines0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["break-lines"] = v_23_auto
  break_lines = v_23_auto
end
local set_win_opts_21
do
  local v_23_auto
  local function set_win_opts_210(win)
    local function _15_()
      if config["get-in"]({"log", "wrap"}) then
        return true
      else
        return false
      end
    end
    nvim.win_set_option(win, "wrap", _15_())
    nvim.win_set_option(win, "foldmethod", "marker")
    nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
    return nvim.win_set_option(win, "foldlevel", 0)
  end
  v_23_auto = set_win_opts_210
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["set-win-opts!"] = v_23_auto
  set_win_opts_21 = v_23_auto
end
local in_box_3f
do
  local v_23_auto
  local function in_box_3f0(box, pos)
    return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
  end
  v_23_auto = in_box_3f0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["in-box?"] = v_23_auto
  in_box_3f = v_23_auto
end
local flip_anchor
do
  local v_23_auto
  local function flip_anchor0(anchor, n)
    local chars = {anchor:sub(1, 1), anchor:sub(2)}
    local flip = {E = "W", N = "S", S = "N", W = "E"}
    local function _16_(_241)
      return a.get(flip, _241)
    end
    return str.join(a.update(chars, n, _16_))
  end
  v_23_auto = flip_anchor0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["flip-anchor"] = v_23_auto
  flip_anchor = v_23_auto
end
local pad_box
do
  local v_23_auto
  local function pad_box0(box, padding)
    local function _17_(_241)
      return (_241 - padding.x)
    end
    local function _18_(_241)
      return (_241 - padding.y)
    end
    local function _19_(_241)
      return (_241 + padding.x)
    end
    local function _20_(_241)
      return (_241 + padding.y)
    end
    return a.update(a.update(a.update(a.update(box, "x1", _17_), "y1", _18_), "x2", _19_), "y2", _20_)
  end
  v_23_auto = pad_box0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["pad-box"] = v_23_auto
  pad_box = v_23_auto
end
local hud_window_pos
do
  local v_23_auto
  local function hud_window_pos0(anchor, size, rec_3f)
    local north = 0
    local west = 0
    local south = (editor.height() - 2)
    local east = editor.width()
    local padding_percent = config["get-in"]({"log", "hud", "overlap_padding"})
    local pos
    local _21_
    if ("NE" == anchor) then
      _21_ = {box = {x1 = (east - size.width), x2 = east, y1 = north, y2 = (north + size.height)}, col = east, row = north}
    elseif ("SE" == anchor) then
      _21_ = {box = {x1 = (east - size.width), x2 = east, y1 = (south - size.height), y2 = south}, col = east, row = south}
    elseif ("SW" == anchor) then
      _21_ = {box = {x1 = west, x2 = (west + size.width), y1 = (south - size.height), y2 = south}, col = west, row = south}
    elseif ("NW" == anchor) then
      _21_ = {box = {x1 = west, x2 = (west + size.width), y1 = north, y2 = (north + size.height)}, col = west, row = north}
    else
      nvim.err_writeln("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
      _21_ = hud_window_pos0("NE", size)
    end
    pos = a.assoc(_21_, "anchor", anchor)
    if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
      local function _23_()
        if (size.width > size.height) then
          return 1
        else
          return 2
        end
      end
      return hud_window_pos0(flip_anchor(anchor, _23_()), size, true)
    else
      return pos
    end
  end
  v_23_auto = hud_window_pos0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["hud-window-pos"] = v_23_auto
  hud_window_pos = v_23_auto
end
local display_hud
do
  local v_23_auto
  local function display_hud0()
    if config["get-in"]({"log", "hud", "enabled"}) then
      clear_close_hud_passive_timer()
      local buf = upsert_buf()
      local last_break = a.last(break_lines(buf))
      local line_count = nvim.buf_line_count(buf)
      local size = {height = editor["percent-height"](config["get-in"]({"log", "hud", "height"})), width = editor["percent-width"](config["get-in"]({"log", "hud", "width"}))}
      local pos = hud_window_pos(config["get-in"]({"log", "hud", "anchor"}), size)
      local border = config["get-in"]({"log", "hud", "border"})
      local win_opts
      local function _25_()
        if (1 == nvim.fn.has("nvim-0.5")) then
          return {border = border}
        end
      end
      win_opts = a.merge({anchor = pos.anchor, col = pos.col, focusable = false, height = size.height, relative = "editor", row = pos.row, style = "minimal", width = size.width}, _25_())
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
  v_23_auto = display_hud0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-hud"] = v_23_auto
  display_hud = v_23_auto
end
local win_visible_3f
do
  local v_23_auto
  local function win_visible_3f0(win)
    return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
  end
  v_23_auto = win_visible_3f0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["win-visible?"] = v_23_auto
  win_visible_3f = v_23_auto
end
local with_buf_wins
do
  local v_23_auto
  local function with_buf_wins0(buf, f)
    local function _30_(win)
      if (buf == nvim.win_get_buf(win)) then
        return f(win)
      end
    end
    return a["run!"](_30_, nvim.list_wins())
  end
  v_23_auto = with_buf_wins0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-buf-wins"] = v_23_auto
  with_buf_wins = v_23_auto
end
local win_botline
do
  local v_23_auto
  local function win_botline0(win)
    return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
  end
  v_23_auto = win_botline0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["win-botline"] = v_23_auto
  win_botline = v_23_auto
end
local trim
do
  local v_23_auto
  local function trim0(buf)
    local line_count = nvim.buf_line_count(buf)
    if (line_count > config["get-in"]({"log", "trim", "at"})) then
      local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
      local break_line
      local function _32_(line)
        if (line >= target_line_count) then
          return line
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
      end
    end
  end
  v_23_auto = trim0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["trim"] = v_23_auto
  trim = v_23_auto
end
local last_line
do
  local v_23_auto
  do
    local v_25_auto
    local function last_line0(buf, extra_offset)
      return a.first(nvim.buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
    end
    v_25_auto = last_line0
    _1_["last-line"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["last-line"] = v_23_auto
  last_line = v_23_auto
end
local append
do
  local v_23_auto
  do
    local v_25_auto
    local function append0(lines, opts)
      local line_count = a.count(lines)
      if (line_count > 0) then
        local visible_scrolling_log_3f = false
        local buf = upsert_buf()
        local join_first_3f = a.get(opts, "join-first?")
        local lines0
        local function _38_(s)
          return s:gsub("\n", "\226\134\181")
        end
        lines0 = a.map(_38_, lines)
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
          local _41_
          if client["multiple-states?"]() then
            _41_ = {state_key_header()}
          else
          _41_ = nil
          end
          lines3 = a.concat({_break()}, _41_, lines2)
        elseif join_first_3f then
          local _43_
          if last_fold_3f then
            _43_ = {(last_line(buf, -1) .. a.first(lines2)), fold_marker_end}
          else
            _43_ = {(last_line(buf) .. a.first(lines2))}
          end
          lines3 = a.concat(_43_, a.rest(lines2))
        else
          lines3 = lines2
        end
        local old_lines = nvim.buf_line_count(buf)
        do
          local ok_3f, err = nil, nil
          local function _46_()
            local _47_
            if buffer["empty?"](buf) then
              _47_ = 0
            elseif join_first_3f then
              if last_fold_3f then
                _47_ = -3
              else
                _47_ = -2
              end
            else
              _47_ = -1
            end
            return nvim.buf_set_lines(buf, _47_, -1, false, lines3)
          end
          ok_3f, err = pcall(_46_)
          if not ok_3f then
            error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a["pr-str"](lines3)))
          end
        end
        do
          local new_lines = nvim.buf_line_count(buf)
          local function _51_(win)
            local _let_52_ = nvim.win_get_cursor(win)
            local row = _let_52_[1]
            local col = _let_52_[2]
            if ((win ~= state.hud.id) and win_visible_3f(win) and (win_botline(win) >= old_lines)) then
              visible_scrolling_log_3f = true
            end
            if (row == old_lines) then
              return nvim.win_set_cursor(win, {new_lines, 0})
            end
          end
          with_buf_wins(buf, _51_)
        end
        if (not a.get(opts, "suppress-hud?") and not visible_scrolling_log_3f) then
          display_hud()
        else
          close_hud()
        end
        return trim(buf)
      end
    end
    v_25_auto = append0
    _1_["append"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["append"] = v_23_auto
  append = v_23_auto
end
local create_win
do
  local v_23_auto
  local function create_win0(cmd)
    local buf = upsert_buf()
    local _57_
    if config["get-in"]({"log", "botright"}) then
      _57_ = "botright "
    else
      _57_ = ""
    end
    nvim.command(("keepalt " .. _57_ .. cmd .. " " .. buffer.resolve(log_buf_name())))
    nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
    set_win_opts_21(0)
    return buffer.unlist(buf)
  end
  v_23_auto = create_win0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["create-win"] = v_23_auto
  create_win = v_23_auto
end
local split
do
  local v_23_auto
  do
    local v_25_auto
    local function split0()
      return create_win("split")
    end
    v_25_auto = split0
    _1_["split"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["split"] = v_23_auto
  split = v_23_auto
end
local vsplit
do
  local v_23_auto
  do
    local v_25_auto
    local function vsplit0()
      return create_win("vsplit")
    end
    v_25_auto = vsplit0
    _1_["vsplit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["vsplit"] = v_23_auto
  vsplit = v_23_auto
end
local tab
do
  local v_23_auto
  do
    local v_25_auto
    local function tab0()
      return create_win("tabnew")
    end
    v_25_auto = tab0
    _1_["tab"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["tab"] = v_23_auto
  tab = v_23_auto
end
local close_visible
do
  local v_23_auto
  do
    local v_25_auto
    local function close_visible0()
      local buf = upsert_buf()
      close_hud()
      local function _59_(_241)
        return nvim.win_close(_241, true)
      end
      local function _60_(win)
        return (buf == nvim.win_get_buf(win))
      end
      return a["run!"](_59_, a.filter(_60_, nvim.tabpage_list_wins(0)))
    end
    v_25_auto = close_visible0
    _1_["close-visible"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-visible"] = v_23_auto
  close_visible = v_23_auto
end
local dbg
do
  local v_23_auto
  do
    local v_25_auto
    local function dbg0(desc, ...)
      if config["get-in"]({"debug"}) then
        append(a.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](a["pr-str"](...))))
      end
      return ...
    end
    v_25_auto = dbg0
    _1_["dbg"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["dbg"] = v_23_auto
  dbg = v_23_auto
end
local reset_soft
do
  local v_23_auto
  do
    local v_25_auto
    local function reset_soft0()
      return on_new_log_buf(upsert_buf())
    end
    v_25_auto = reset_soft0
    _1_["reset-soft"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["reset-soft"] = v_23_auto
  reset_soft = v_23_auto
end
local reset_hard
do
  local v_23_auto
  do
    local v_25_auto
    local function reset_hard0()
      return nvim.ex.bwipeout_(upsert_buf())
    end
    v_25_auto = reset_hard0
    _1_["reset-hard"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["reset-hard"] = v_23_auto
  reset_hard = v_23_auto
end
return nil