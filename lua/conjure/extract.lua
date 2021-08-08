local _2afile_2a = "fnl/conjure/extract.fnl"
local _1_
do
  local name_4_auto = "conjure.extract"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.nvim.util"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.tree-sitter")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", nu = "conjure.aniseed.nvim.util", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", ts = "conjure.tree-sitter"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local config = _local_4_[3]
local nu = _local_4_[4]
local nvim = _local_4_[5]
local str = _local_4_[6]
local ts = _local_4_[7]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.extract"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local read_range
do
  local v_23_auto
  local function read_range0(_8_, _10_)
    local _arg_9_ = _8_
    local srow = _arg_9_[1]
    local scol = _arg_9_[2]
    local _arg_11_ = _10_
    local erow = _arg_11_[1]
    local ecol = _arg_11_[2]
    local lines = nvim.buf_get_lines(0, (srow - 1), erow, false)
    local function _12_(s)
      return string.sub(s, 0, ecol)
    end
    local function _13_(s)
      return string.sub(s, scol)
    end
    return str.join("\n", a.update(a.update(lines, #lines, _12_), 1, _13_))
  end
  v_23_auto = read_range0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["read-range"] = v_23_auto
  read_range = v_23_auto
end
local current_char
do
  local v_23_auto
  local function current_char0()
    local _let_14_ = nvim.win_get_cursor(0)
    local row = _let_14_[1]
    local col = _let_14_[2]
    local _let_15_ = nvim.buf_get_lines(0, (row - 1), row, false)
    local line = _let_15_[1]
    local char = (col + 1)
    return string.sub(line, char, char)
  end
  v_23_auto = current_char0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["current-char"] = v_23_auto
  current_char = v_23_auto
end
local nil_pos_3f
do
  local v_23_auto
  local function nil_pos_3f0(pos)
    return (not pos or (0 == unpack(pos)))
  end
  v_23_auto = nil_pos_3f0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["nil-pos?"] = v_23_auto
  nil_pos_3f = v_23_auto
end
local skip_match_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function skip_match_3f0()
      local _let_16_ = nvim.win_get_cursor(0)
      local row = _let_16_[1]
      local col = _let_16_[2]
      local stack = nvim.fn.synstack(row, a.inc(col))
      local stack_size = #stack
      local function _17_()
        local name = nvim.fn.synIDattr(stack[stack_size], "name")
        return (name:find("Comment$") or name:find("String$") or name:find("Regexp%?$"))
      end
      if (("number" == type(((stack_size > 0) and _17_()))) or ("\\" == string.sub(a.first(nvim.buf_get_lines(nvim.win_get_buf(0), (row - 1), row, false)), col, col))) then
        return 1
      else
        return 0
      end
    end
    v_25_auto = skip_match_3f0
    _1_["skip-match?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["skip-match?"] = v_23_auto
  skip_match_3f = v_23_auto
end
local form_2a
do
  local v_23_auto
  local function form_2a0(_19_, _21_)
    local _arg_20_ = _19_
    local start_char = _arg_20_[1]
    local end_char = _arg_20_[2]
    local escape_3f = _arg_20_[3]
    local _arg_22_ = _21_
    local root_3f = _arg_22_["root?"]
    local flags
    local _23_
    if root_3f then
      _23_ = "r"
    else
      _23_ = ""
    end
    flags = ("Wnz" .. _23_)
    local cursor_char = current_char()
    local skip_match_3f_viml = "luaeval(\"require('conjure.extract')['skip-match?']()\")"
    local safe_start_char
    if escape_3f then
      safe_start_char = ("\\" .. start_char)
    else
      safe_start_char = start_char
    end
    local safe_end_char
    if escape_3f then
      safe_end_char = ("\\" .. end_char)
    else
      safe_end_char = end_char
    end
    local start
    local _27_
    if (cursor_char == start_char) then
      _27_ = "c"
    else
      _27_ = ""
    end
    start = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. "b" .. _27_), skip_match_3f_viml)
    local _end
    local _29_
    if (cursor_char == end_char) then
      _29_ = "c"
    else
      _29_ = ""
    end
    _end = nvim.fn.searchpairpos(safe_start_char, "", safe_end_char, (flags .. _29_), skip_match_3f_viml)
    if (not nil_pos_3f(start) and not nil_pos_3f(_end)) then
      return {content = read_range(start, _end), range = {["end"] = a.update(_end, 2, a.dec), start = a.update(start, 2, a.dec)}}
    end
  end
  v_23_auto = form_2a0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["form*"] = v_23_auto
  form_2a = v_23_auto
end
local range_distance
do
  local v_23_auto
  local function range_distance0(range)
    local _let_32_ = range.start
    local sl = _let_32_[1]
    local sc = _let_32_[2]
    local _let_33_ = range["end"]
    local el = _let_33_[1]
    local ec = _let_33_[2]
    return {(sl - el), (sc - ec)}
  end
  v_23_auto = range_distance0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["range-distance"] = v_23_auto
  range_distance = v_23_auto
end
local distance_gt
do
  local v_23_auto
  local function distance_gt0(_34_, _36_)
    local _arg_35_ = _34_
    local al = _arg_35_[1]
    local ac = _arg_35_[2]
    local _arg_37_ = _36_
    local bl = _arg_37_[1]
    local bc = _arg_37_[2]
    return ((al > bl) or ((al == bl) and (ac > bc)))
  end
  v_23_auto = distance_gt0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["distance-gt"] = v_23_auto
  distance_gt = v_23_auto
end
local form
do
  local v_23_auto
  do
    local v_25_auto
    local function form0(opts)
      if ts["enabled?"]() then
        local node
        if opts["root?"] then
          node = ts["get-root"]()
        else
          node = ts["get-form"]()
        end
        if node then
          return {content = ts["node->str"](node), range = ts.range(node)}
        end
      else
        local forms
        local function _40_(_241)
          return form_2a(_241, opts)
        end
        forms = a.filter(a["table?"], a.map(_40_, config["get-in"]({"extract", "form_pairs"})))
        local function _41_(_241, _242)
          return distance_gt(range_distance(_241.range), range_distance(_242.range))
        end
        table.sort(forms, _41_)
        if opts["root?"] then
          return a.last(forms)
        else
          return a.first(forms)
        end
      end
    end
    v_25_auto = form0
    _1_["form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["form"] = v_23_auto
  form = v_23_auto
end
local word
do
  local v_23_auto
  do
    local v_25_auto
    local function word0()
      return {content = nvim.fn.expand("<cword>"), range = {["end"] = nvim.win_get_cursor(0), start = nvim.win_get_cursor(0)}}
    end
    v_25_auto = word0
    _1_["word"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["word"] = v_23_auto
  word = v_23_auto
end
local file_path
do
  local v_23_auto
  do
    local v_25_auto
    local function file_path0()
      return nvim.fn.expand("%:p")
    end
    v_25_auto = file_path0
    _1_["file-path"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["file-path"] = v_23_auto
  file_path = v_23_auto
end
local buf_last_line_length
do
  local v_23_auto
  local function buf_last_line_length0(buf)
    return a.count(a.first(nvim.buf_get_lines(buf, a.dec(nvim.buf_line_count(buf)), -1, false)))
  end
  v_23_auto = buf_last_line_length0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-last-line-length"] = v_23_auto
  buf_last_line_length = v_23_auto
end
local range
do
  local v_23_auto
  do
    local v_25_auto
    local function range0(start, _end)
      return {content = str.join("\n", nvim.buf_get_lines(0, start, _end, false)), range = {["end"] = {_end, buf_last_line_length(0)}, start = {a.inc(start), 0}}}
    end
    v_25_auto = range0
    _1_["range"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["range"] = v_23_auto
  range = v_23_auto
end
local buf
do
  local v_23_auto
  do
    local v_25_auto
    local function buf0()
      return range(0, -1)
    end
    v_25_auto = buf0
    _1_["buf"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf"] = v_23_auto
  buf = v_23_auto
end
local getpos
do
  local v_23_auto
  local function getpos0(expr)
    local _let_44_ = nvim.fn.getpos(expr)
    local _ = _let_44_[1]
    local start = _let_44_[2]
    local _end = _let_44_[3]
    local _0 = _let_44_[4]
    return {start, a.dec(_end)}
  end
  v_23_auto = getpos0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["getpos"] = v_23_auto
  getpos = v_23_auto
end
local selection
do
  local v_23_auto
  do
    local v_25_auto
    local function selection0(_45_)
      local _arg_46_ = _45_
      local kind = _arg_46_["kind"]
      local visual_3f = _arg_46_["visual?"]
      local sel_backup = nvim.o.selection
      nvim.ex.let("g:conjure_selection_reg_backup = @@")
      nvim.o.selection = "inclusive"
      if visual_3f then
        nu.normal(("`<" .. kind .. "`>y"))
      elseif (kind == "line") then
        nu.normal("'[V']y")
      elseif (kind == "block") then
        nu.normal("`[\22`]y")
      else
        nu.normal("`[v`]y")
      end
      local content = nvim.eval("@@")
      nvim.o.selection = sel_backup
      nvim.ex.let("@@ = g:conjure_selection_reg_backup")
      return {content = content, range = {["end"] = getpos("'>"), start = getpos("'<")}}
    end
    v_25_auto = selection0
    _1_["selection"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["selection"] = v_23_auto
  selection = v_23_auto
end
local context
do
  local v_23_auto
  do
    local v_25_auto
    local function context0()
      local pat = client.get("context-pattern")
      local f
      if pat then
        local function _48_(_241)
          return string.match(_241, pat)
        end
        f = _48_
      else
        f = client.get("context")
      end
      if f then
        return f(str.join("\n", nvim.buf_get_lines(0, 0, config["get-in"]({"extract", "context_header_lines"}), false)))
      end
    end
    v_25_auto = context0
    _1_["context"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["context"] = v_23_auto
  context = v_23_auto
end
local prompt
do
  local v_23_auto
  do
    local v_25_auto
    local function prompt0(prefix)
      local ok_3f, val = nil, nil
      local function _51_()
        return nvim.fn.input((prefix or ""))
      end
      ok_3f, val = pcall(_51_)
      if ok_3f then
        return val
      end
    end
    v_25_auto = prompt0
    _1_["prompt"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prompt"] = v_23_auto
  prompt = v_23_auto
end
local prompt_char
do
  local v_23_auto
  do
    local v_25_auto
    local function prompt_char0()
      return nvim.fn.nr2char(nvim.fn.getchar())
    end
    v_25_auto = prompt_char0
    _1_["prompt-char"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prompt-char"] = v_23_auto
  prompt_char = v_23_auto
end
return nil