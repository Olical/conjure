local _0_0 = nil
do
  local name_0_ = "conjure.log"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.nvim"), require("conjure.sponsors"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.timer"), require("conjure.aniseed.view")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", nvim = "conjure.aniseed.nvim", sponsors = "conjure.sponsors", str = "conjure.aniseed.string", text = "conjure.text", timer = "conjure.timer", view = "conjure.aniseed.view"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local timer = _1_[10]
local view = _1_[11]
local buffer = _1_[2]
local client = _1_[3]
local config = _1_[4]
local editor = _1_[5]
local nvim = _1_[6]
local sponsors = _1_[7]
local str = _1_[8]
local text = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.log"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local state = nil
do
  local v_0_ = (_0_0["aniseed/locals"].state or {hud = {id = nil, timer = nil}})
  _0_0["aniseed/locals"]["state"] = v_0_
  state = v_0_
end
local _break = nil
do
  local v_0_ = nil
  local function _break0()
    return (client.get("comment-prefix") .. string.rep("-", config["get-in"]({"log", "break_length"})))
  end
  v_0_ = _break0
  _0_0["aniseed/locals"]["break"] = v_0_
  _break = v_0_
end
local state_key_header = nil
do
  local v_0_ = nil
  local function state_key_header0()
    return (client.get("comment-prefix") .. "State: " .. client["state-key"]())
  end
  v_0_ = state_key_header0
  _0_0["aniseed/locals"]["state-key-header"] = v_0_
  state_key_header = v_0_
end
local log_buf_name = nil
do
  local v_0_ = nil
  local function log_buf_name0()
    return ("conjure-log-" .. nvim.fn.getpid() .. client.get("buf-suffix"))
  end
  v_0_ = log_buf_name0
  _0_0["aniseed/locals"]["log-buf-name"] = v_0_
  log_buf_name = v_0_
end
local log_buf_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function log_buf_3f0(name)
      return name:match((log_buf_name() .. "$"))
    end
    v_0_0 = log_buf_3f0
    _0_0["log-buf?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["log-buf?"] = v_0_
  log_buf_3f = v_0_
end
local on_new_log_buf = nil
do
  local v_0_ = nil
  local function on_new_log_buf0(buf)
    return nvim.buf_set_lines(buf, 0, -1, false, {(client.get("comment-prefix") .. "Sponsored by @" .. a.get(sponsors, a.inc(math.floor(a.rand(a.dec(a.count(sponsors)))))) .. " \226\157\164")})
  end
  v_0_ = on_new_log_buf0
  _0_0["aniseed/locals"]["on-new-log-buf"] = v_0_
  on_new_log_buf = v_0_
end
local upsert_buf = nil
do
  local v_0_ = nil
  local function upsert_buf0()
    return buffer["upsert-hidden"](log_buf_name(), on_new_log_buf)
  end
  v_0_ = upsert_buf0
  _0_0["aniseed/locals"]["upsert-buf"] = v_0_
  upsert_buf = v_0_
end
local clear_close_hud_passive_timer = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function clear_close_hud_passive_timer0()
      return a["update-in"](state, {"hud", "timer"}, timer.destroy)
    end
    v_0_0 = clear_close_hud_passive_timer0
    _0_0["clear-close-hud-passive-timer"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["clear-close-hud-passive-timer"] = v_0_
  clear_close_hud_passive_timer = v_0_
end
local close_hud = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["close-hud"] = v_0_
  close_hud = v_0_
end
local close_hud_passive = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["close-hud-passive"] = v_0_
  close_hud_passive = v_0_
end
local break_lines = nil
do
  local v_0_ = nil
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
  v_0_ = break_lines0
  _0_0["aniseed/locals"]["break-lines"] = v_0_
  break_lines = v_0_
end
local set_win_opts_21 = nil
do
  local v_0_ = nil
  local function set_win_opts_210(win)
    local function _3_()
      if config["get-in"]({"log", "wrap"}) then
        return true
      else
        return false
      end
    end
    nvim.win_set_option(win, "wrap", _3_())
    nvim.win_set_option(win, "foldmethod", "marker")
    nvim.win_set_option(win, "foldmarker", (config["get-in"]({"log", "fold", "marker", "start"}) .. "," .. config["get-in"]({"log", "fold", "marker", "end"})))
    return nvim.win_set_option(win, "foldlevel", 0)
  end
  v_0_ = set_win_opts_210
  _0_0["aniseed/locals"]["set-win-opts!"] = v_0_
  set_win_opts_21 = v_0_
end
local display_hud = nil
do
  local v_0_ = nil
  local function display_hud0()
    if config["get-in"]({"log", "hud", "enabled"}) then
      clear_close_hud_passive_timer()
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
      win_opts = {anchor = "SE", col = editor.width(), focusable = false, height = editor["percent-height"](config["get-in"]({"log", "hud", "height"})), relative = "editor", row = _3_, style = "minimal", width = editor["percent-width"](config["get-in"]({"log", "hud", "width"}))}
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
  _0_0["aniseed/locals"]["display-hud"] = v_0_
  display_hud = v_0_
end
local win_visible_3f = nil
do
  local v_0_ = nil
  local function win_visible_3f0(win)
    return (nvim.fn.tabpagenr() == a.first(nvim.fn.win_id2tabwin(win)))
  end
  v_0_ = win_visible_3f0
  _0_0["aniseed/locals"]["win-visible?"] = v_0_
  win_visible_3f = v_0_
end
local with_buf_wins = nil
do
  local v_0_ = nil
  local function with_buf_wins0(buf, f)
    local function _3_(win)
      if (buf == nvim.win_get_buf(win)) then
        return f(win)
      end
    end
    return a["run!"](_3_, nvim.list_wins())
  end
  v_0_ = with_buf_wins0
  _0_0["aniseed/locals"]["with-buf-wins"] = v_0_
  with_buf_wins = v_0_
end
local win_botline = nil
do
  local v_0_ = nil
  local function win_botline0(win)
    return a.get(a.first(nvim.fn.getwininfo(win)), "botline")
  end
  v_0_ = win_botline0
  _0_0["aniseed/locals"]["win-botline"] = v_0_
  win_botline = v_0_
end
local trim = nil
do
  local v_0_ = nil
  local function trim0(buf)
    local line_count = nvim.buf_line_count(buf)
    if (line_count > config["get-in"]({"log", "trim", "at"})) then
      local target_line_count = (line_count - config["get-in"]({"log", "trim", "to"}))
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
  v_0_ = trim0
  _0_0["aniseed/locals"]["trim"] = v_0_
  trim = v_0_
end
local last_line = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function last_line0(buf, extra_offset)
      return a.first(nvim.buf_get_lines((buf or upsert_buf()), (-2 + (extra_offset or 0)), -1, false))
    end
    v_0_0 = last_line0
    _0_0["last-line"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["last-line"] = v_0_
  last_line = v_0_
end
local append = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function append0(lines, opts)
      local line_count = a.count(lines)
      if (line_count > 0) then
        local visible_scrolling_log_3f = false
        local buf = upsert_buf()
        local join_first_3f = a.get(opts, "join-first?")
        local lines0 = nil
        if (line_count <= config["get-in"]({"log", "strip_ansi_escape_sequences_line_limit"})) then
          lines0 = a.map(text["strip-ansi-escape-sequences"], lines)
        else
          lines0 = lines
        end
        local comment_prefix = client.get("comment-prefix")
        local fold_marker_end = str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "end"})})
        local lines1 = nil
        if (not a.get(opts, "break?") and not join_first_3f and config["get-in"]({"log", "fold", "enabled"}) and (a.count(lines0) >= config["get-in"]({"log", "fold", "lines"}))) then
          lines1 = a.concat({str.join({comment_prefix, config["get-in"]({"log", "fold", "marker", "start"}), " ", text["left-sample"](str.join("\n", lines0), editor["percent-width"](config["get-in"]({"preview", "sample_limit"})))})}, lines0, {fold_marker_end})
        else
          lines1 = lines0
        end
        local last_fold_3f = (fold_marker_end == last_line(buf))
        local lines2 = nil
        if a.get(opts, "break?") then
          local _5_
          if client["multiple-states?"]() then
            _5_ = {state_key_header()}
          else
          _5_ = nil
          end
          lines2 = a.concat({_break()}, _5_, lines1)
        elseif join_first_3f then
          local _5_
          if last_fold_3f then
            _5_ = {(last_line(buf, -1) .. a.first(lines1)), fold_marker_end}
          else
            _5_ = {(last_line(buf) .. a.first(lines1))}
          end
          lines2 = a.concat(_5_, a.rest(lines1))
        else
          lines2 = lines1
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
            return nvim.buf_set_lines(buf, _7_, -1, false, lines2)
          end
          ok_3f, err = pcall(_6_)
          if not ok_3f then
            error(("Conjure failed to append to log: " .. err .. "\n" .. "Offending lines: " .. a["pr-str"](lines2)))
          end
        end
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
    v_0_0 = append0
    _0_0["append"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["append"] = v_0_
  append = v_0_
end
local create_win = nil
do
  local v_0_ = nil
  local function create_win0(cmd)
    local buf = upsert_buf()
    local _3_
    if config["get-in"]({"log", "botright"}) then
      _3_ = "botright "
    else
      _3_ = ""
    end
    nvim.command((_3_ .. cmd .. " " .. buffer.resolve(log_buf_name())))
    nvim.win_set_cursor(0, {nvim.buf_line_count(buf), 0})
    set_win_opts_21(0)
    return buffer.unlist(buf)
  end
  v_0_ = create_win0
  _0_0["aniseed/locals"]["create-win"] = v_0_
  create_win = v_0_
end
local split = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function split0()
      return create_win("split")
    end
    v_0_0 = split0
    _0_0["split"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["split"] = v_0_
  split = v_0_
end
local vsplit = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function vsplit0()
      return create_win("vsplit")
    end
    v_0_0 = vsplit0
    _0_0["vsplit"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["vsplit"] = v_0_
  vsplit = v_0_
end
local tab = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function tab0()
      return create_win("tabnew")
    end
    v_0_0 = tab0
    _0_0["tab"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["tab"] = v_0_
  tab = v_0_
end
local close_visible = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = close_visible0
    _0_0["close-visible"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["close-visible"] = v_0_
  close_visible = v_0_
end
local dbg = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["dbg"] = v_0_
  dbg = v_0_
end
local reset_soft = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function reset_soft0()
      return on_new_log_buf(upsert_buf())
    end
    v_0_0 = reset_soft0
    _0_0["reset-soft"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["reset-soft"] = v_0_
  reset_soft = v_0_
end
local reset_hard = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function reset_hard0()
      return nvim.ex.bwipeout_(upsert_buf())
    end
    v_0_0 = reset_hard0
    _0_0["reset-hard"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["reset-hard"] = v_0_
  reset_hard = v_0_
end
return nil