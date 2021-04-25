local _0_0
do
  local name_0_ = "conjure.log"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.aniseed.view"), require("conjure.sponsors")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text", timer = "conjure.timer", view = "conjure.aniseed.view"}, require = {sponsors = "conjure.sponsors"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local view = _local_0_[10]
local sponsors = _local_0_[11]
local buffer = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local editor = _local_0_[5]
local nvim = _local_0_[6]
local str = _local_0_[7]
local text = _local_0_[8]
local timer = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.log"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local state
do
  local v_0_ = (((_0_0)["aniseed/locals"]).state or {hud = {id = nil, timer = nil}})
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["state"] = v_0_
  state = v_0_
end
local _break
do
  local v_0_
  local function _break0()
    return (client.get("comment-prefix") .. string.rep("-", config["get-in"]({"log", "break_length"})))
  end
  v_0_ = _break0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["break"] = v_0_
  _break = v_0_
end
local state_key_header
do
  local v_0_
  local function state_key_header0()
    return (client.get("comment-prefix") .. "State: " .. client["state-key"]())
  end
  v_0_ = state_key_header0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["state-key-header"] = v_0_
  state_key_header = v_0_
end
local log_buf_name
do
  local v_0_
  local function log_buf_name0()
    return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
  end
  v_0_ = log_buf_name0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["log-buf-name"] = v_0_
  log_buf_name = v_0_
end
local log_buf_3f
do
  local v_0_
  do
    local v_0_0
    local function log_buf_3f0(name)
      return name:match((log_buf_name() .. "$"))
    end
    v_0_0 = log_buf_3f0
    _0_0["log-buf?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["log-buf?"] = v_0_
  log_buf_3f = v_0_
end
local on_new_log_buf
do
  local v_0_
  local function on_new_log_buf0(buf)
    return nvim.buf_set_lines(buf, 0, -1, false, {(client.get("comment-prefix") .. "Sponsored by @" .. a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))) .. " \226\157\164")})
  end
  v_0_ = on_new_log_buf0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["on-new-log-buf"] = v_0_
  on_new_log_buf = v_0_
end
local upsert_buf
do
  local v_0_
  local function upsert_buf0()
    return buffer["upsert-hidden"](log_buf_name(), on_new_log_buf)
  end
  v_0_ = upsert_buf0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["upsert-buf"] = v_0_
  upsert_buf = v_0_
end
local clear_close_hud_passive_timer
do
  local v_0_
  do
    local v_0_0
    local function clear_close_hud_passive_timer0()
      return a["update-in"](state, {"hud", "timer"}, timer.destroy)
    end
    v_0_0 = clear_close_hud_passive_timer0
    _0_0["clear-close-hud-passive-timer"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["clear-close-hud-passive-timer"] = v_0_
  clear_close_hud_passive_timer = v_0_
end
local close_hud
do
  local v_0_
  do
    local v_0_0
    local function close_hud0()
      clear_close_hud_passive_timer()
      if state.hud.id then
        pcall(nvim.win_close, state.hud.id, true)
        state.hud.id = nil
        return nil
      end
    end
    v_0_0 = close_hud0
    _0_0["close-hud"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["close-hud"] = v_0_
  close_hud = v_0_
end
local close_hud_passive
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = close_hud_passive0
    _0_0["close-hud-passive"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["close-hud-passive"] = v_0_
  close_hud_passive = v_0_
end
local break_lines
do
  local v_0_
  local function break_lines0(buf)
    local break_str = _break()
    local function _3_(_2_0)
      local _arg_0_ = _2_0
      local n = _arg_0_[1]
      local s = _arg_0_[2]
      return (s == break_str)
    end
    return a.map(a.first, a.filter(_3_, a["kv-pairs"](nvim.buf_get_lines(buf, 0, -1, false))))
  end
  v_0_ = break_lines0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["break-lines"] = v_0_
  break_lines = v_0_
end
local set_win_opts_21
do
  local v_0_
  local function set_win_opts_210(win)
    local function _2_()
      if config["get-in"]({"log", "wrap"}) then
        return true
      else
        return false
      end
    end
    nvim.win_set_option(win, "wrap", _2_())
    nvim.win_set_option(win, "foldmethod", "marker")
    nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
    return nvim.win_set_option(win, "foldlevel", 0)
  end
  v_0_ = set_win_opts_210
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["set-win-opts!"] = v_0_
  set_win_opts_21 = v_0_
end
local in_box_3f
do
  local v_0_
  local function in_box_3f0(box, pos)
    return ((pos.x >= box.x1) and (pos.x <= box.x2) and (pos.y >= box.y1) and (pos.y <= box.y2))
  end
  v_0_ = in_box_3f0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["in-box?"] = v_0_
  in_box_3f = v_0_
end
local flip_anchor
do
  local v_0_
  local function flip_anchor0(anchor, n)
    local chars = {anchor:sub(1, 1), anchor:sub(2)}
    local flip = {E = "W", N = "S", S = "N", W = "E"}
    local function _2_(_241)
      return a.get(flip, _241)
    end
    return str.join(a.update(chars, n, _2_))
  end
  v_0_ = flip_anchor0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["flip-anchor"] = v_0_
  flip_anchor = v_0_
end
local pad_box
do
  local v_0_
  local function pad_box0(box, padding)
    local function _2_(_241)
      return (_241 - padding.x)
    end
    local function _3_(_241)
      return (_241 - padding.y)
    end
    local function _4_(_241)
      return (_241 + padding.x)
    end
    local function _5_(_241)
      return (_241 + padding.y)
    end
    return a.update(a.update(a.update(a.update(box, "x1", _2_), "y1", _3_), "x2", _4_), "y2", _5_)
  end
  v_0_ = pad_box0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["pad-box"] = v_0_
  pad_box = v_0_
end
local hud_window_pos
do
  local v_0_
  local function hud_window_pos0(anchor, size, rec_3f)
    local north = 0
    local west = 0
    local south = (editor.height() - 2)
    local east = editor.width()
    local padding_percent = config["get-in"]({"log", "hud", "overlap_padding"})
    local pos
    local _2_
    if ("NE" == anchor) then
      _2_ = {box = {x1 = (east - size.width), x2 = east, y1 = north, y2 = (north + size.height)}, col = east, row = north}
    elseif ("SE" == anchor) then
      _2_ = {box = {x1 = (east - size.width), x2 = east, y1 = (south - size.height), y2 = south}, col = east, row = south}
    elseif ("SW" == anchor) then
      _2_ = {box = {x1 = west, x2 = (west + size.width), y1 = (south - size.height), y2 = south}, col = west, row = south}
    elseif ("NW" == anchor) then
      _2_ = {box = {x1 = west, x2 = (west + size.width), y1 = north, y2 = (north + size.height)}, col = west, row = north}
    else
      nvim.err_writeln("g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
      _2_ = hud_window_pos0("NE", size)
    end
    pos = a.assoc(_2_, "anchor", anchor)
    if (not rec_3f and in_box_3f(pad_box(pos.box, {x = editor["percent-width"](padding_percent), y = editor["percent-height"](padding_percent)}), {x = editor["cursor-left"](), y = editor["cursor-top"]()})) then
      local function _4_()
        if (size.width > size.height) then
          return 1
        else
          return 2
        end
      end
      return hud_window_pos0(flip_anchor(anchor, _4_()), size, true)
    else
      return pos
    end
  end
  v_0_ = hud_window_pos0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["hud-window-pos"] = v_0_
  hud_window_pos = v_0_
end
local display_hud
do
  local v_0_
  local function display_hud0()
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
  v_0_ = display_hud0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["display-hud"] = v_0_
  display_hud = v_0_
end
local win_visible_3f
do
  local v_0_
  local function win_visible_3f0(win)
    return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
  end
  v_0_ = win_visible_3f0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["win-visible?"] = v_0_
  win_visible_3f = v_0_
end
local with_buf_wins
do
  local v_0_
  local function with_buf_wins0(buf, f)
    local function _2_(win)
      if (buf == nvim.win_get_buf(win)) then
        return f(win)
      end
    end
    return a["run!"](_2_, nvim.list_wins())
  end
  v_0_ = with_buf_wins0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-buf-wins"] = v_0_
  with_buf_wins = v_0_
end
local win_botline
do
  local v_0_
  local function win_botline0(win)
    return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
  end
  v_0_ = win_botline0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["win-botline"] = v_0_
  win_botline = v_0_
end
local trim
do
  local v_0_
  local function trim0(buf)
    local line_count = nvim.buf_line_count(buf)
    if (line_count > config["get-in"]({"log", "trim", "at"})) then
      local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
      local break_line
      local function _2_(line)
        if (line >= target_line_count) then
          return line
        end
      end
      break_line = a.some(_2_, break_lines(buf))
      if break_line then
        nvim.buf_set_lines(buf, 0, break_line, false, {})
        local line_count0 = nvim.buf_line_count(buf)
        local function _3_(win)
          local _let_0_ = nvim.win_get_cursor(win)
          local row = _let_0_[1]
          local col = _let_0_[2]
          nvim.win_set_cursor(win, {1, 0})
          return nvim.win_set_cursor(win, {row, col})
        end
        return with_buf_wins(buf, _3_)
      end
    end
  end
  v_0_ = trim0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["trim"] = v_0_
  trim = v_0_
end
local last_line
do
  local v_0_
  do
    local v_0_0
    local function last_line0(buf, extra_offset)
      return a.first(nvim.buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
    end
    v_0_0 = last_line0
    _0_0["last-line"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["last-line"] = v_0_
  last_line = v_0_
end
local append
do
  local v_0_
  do
    local v_0_0
    local function append0(lines, opts)
      local line_count = a.count(lines)
      if (line_count > 0) then
        local visible_scrolling_log_3f = false
        local buf = upsert_buf()
        local join_first_3f = a.get(opts, "join-first?")
        local lines0
        local function _2_(s)
          return s:gsub("\n", "\226\134\181")
        end
        lines0 = a.map(_2_, lines)
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
          local _5_
          if client["multiple-states?"]() then
            _5_ = {state_key_header()}
          else
          _5_ = nil
          end
          lines3 = a.concat({_break()}, _5_, lines2)
        elseif join_first_3f then
          local _5_
          if last_fold_3f then
            _5_ = {(last_line(buf, -1) .. a.first(lines2)), fold_marker_end}
          else
            _5_ = {(last_line(buf) .. a.first(lines2))}
          end
          lines3 = a.concat(_5_, a.rest(lines2))
        else
          lines3 = lines2
        end
        local old_lines = nvim.buf_line_count(buf)
        do
          local ok_3f, err = nil, nil
          local function _6_()
            local _7_
            if buffer["empty?"](buf) then
              _7_ = 0
            elseif join_first_3f then
              if last_fold_3f then
                _7_ = -3
              else
                _7_ = -2
              end
            else
              _7_ = -1
            end
            return nvim.buf_set_lines(buf, _7_, -1, false, lines3)
          end
          ok_3f, err = pcall(_6_)
          if not ok_3f then
            error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a["pr-str"](lines3)))
          end
        end
        do
          local new_lines = nvim.buf_line_count(buf)
          local function _6_(win)
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
    v_0_0 = append0
    _0_0["append"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["append"] = v_0_
  append = v_0_
end
local create_win
do
  local v_0_
  local function create_win0(cmd)
    local buf = upsert_buf()
    local _2_
    if config["get-in"]({"log", "botright"}) then
      _2_ = "botright "
    else
      _2_ = ""
    end
    nvim.command(("keepalt " .. _2_ .. cmd .. " " .. buffer.resolve(log_buf_name())))
    nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
    set_win_opts_21(0)
    return buffer.unlist(buf)
  end
  v_0_ = create_win0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["create-win"] = v_0_
  create_win = v_0_
end
local split
do
  local v_0_
  do
    local v_0_0
    local function split0()
      return create_win("split")
    end
    v_0_0 = split0
    _0_0["split"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["split"] = v_0_
  split = v_0_
end
local vsplit
do
  local v_0_
  do
    local v_0_0
    local function vsplit0()
      return create_win("vsplit")
    end
    v_0_0 = vsplit0
    _0_0["vsplit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["vsplit"] = v_0_
  vsplit = v_0_
end
local tab
do
  local v_0_
  do
    local v_0_0
    local function tab0()
      return create_win("tabnew")
    end
    v_0_0 = tab0
    _0_0["tab"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["tab"] = v_0_
  tab = v_0_
end
local close_visible
do
  local v_0_
  do
    local v_0_0
    local function close_visible0()
      local buf = upsert_buf()
      close_hud()
      local function _2_(_241)
        return nvim.win_close(_241, true)
      end
      local function _3_(win)
        return (buf == nvim.win_get_buf(win))
      end
      return a["run!"](_2_, a.filter(_3_, nvim.tabpage_list_wins(0)))
    end
    v_0_0 = close_visible0
    _0_0["close-visible"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["close-visible"] = v_0_
  close_visible = v_0_
end
local dbg
do
  local v_0_
  do
    local v_0_0
    local function dbg0(desc, ...)
      if config["get-in"]({"debug"}) then
        append(a.concat({(client.get("comment-prefix") .. "debug: " .. desc)}, text["split-lines"](a["pr-str"](...))))
      end
      return ...
    end
    v_0_0 = dbg0
    _0_0["dbg"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["dbg"] = v_0_
  dbg = v_0_
end
local reset_soft
do
  local v_0_
  do
    local v_0_0
    local function reset_soft0()
      return on_new_log_buf(upsert_buf())
    end
    v_0_0 = reset_soft0
    _0_0["reset-soft"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["reset-soft"] = v_0_
  reset_soft = v_0_
end
local reset_hard
do
  local v_0_
  do
    local v_0_0
    local function reset_hard0()
      return nvim.ex.bwipeout_(upsert_buf())
    end
    v_0_0 = reset_hard0
    _0_0["reset-hard"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["reset-hard"] = v_0_
  reset_hard = v_0_
end
return nil