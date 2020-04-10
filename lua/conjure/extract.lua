local _0_0 = nil
do
  local name_23_0_ = "conjure.extract"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config", lang = "conjure.lang", nu = "conjure.aniseed.nvim.util", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.lang"), require("conjure.aniseed.nvim.util"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local config = _2_[2]
local lang = _2_[3]
local nu = _2_[4]
local nvim = _2_[5]
local str = _2_[6]
do local _ = ({nil, _0_0, nil})[2] end
local read_range = nil
do
  local v_23_0_ = nil
  local function read_range0(_3_0, _4_0)
    local _4_ = _3_0
    local srow = _4_[1]
    local scol = _4_[2]
    local _5_ = _4_0
    local erow = _5_[1]
    local ecol = _5_[2]
    do
      local lines = nvim.buf_get_lines(0, (srow - 1), erow, false)
      local function _6_(s)
        return string.sub(s, 0, ecol)
      end
      local function _7_(s)
        return string.sub(s, scol)
      end
      return str.join("\n", a.update(a.update(lines, #lines, _6_), 1, _7_))
    end
  end
  v_23_0_ = read_range0
  _0_0["aniseed/locals"]["read-range"] = v_23_0_
  read_range = v_23_0_
end
local current_char = nil
do
  local v_23_0_ = nil
  local function current_char0()
    local _3_ = nvim.win_get_cursor(0)
    local row = _3_[1]
    local col = _3_[2]
    local _4_ = nvim.buf_get_lines(0, (row - 1), row, false)
    local line = _4_[1]
    local char = (col + 1)
    return string.sub(line, char, char)
  end
  v_23_0_ = current_char0
  _0_0["aniseed/locals"]["current-char"] = v_23_0_
  current_char = v_23_0_
end
local nil_pos_3f = nil
do
  local v_23_0_ = nil
  local function nil_pos_3f0(pos)
    return (not pos or (0 == unpack(pos)))
  end
  v_23_0_ = nil_pos_3f0
  _0_0["aniseed/locals"]["nil-pos?"] = v_23_0_
  nil_pos_3f = v_23_0_
end
local skip_match_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function skip_match_3f0()
      local _3_ = nvim.win_get_cursor(0)
      local row = _3_[1]
      local col = _3_[2]
      local stack = nvim.fn.synstack(row, a.inc(col))
      local stack_size = #stack
      local function _4_()
        local name = nvim.fn.synIDattr(stack[stack_size], "name")
        return (name:find("Comment$") or name:find("String$") or name:find("Regexp$"))
      end
      if ("number" == type(((stack_size > 0) and _4_()))) then
        return 1
      else
        return 0
      end
    end
    v_23_0_0 = skip_match_3f0
    _0_0["skip-match?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["skip-match?"] = v_23_0_
  skip_match_3f = v_23_0_
end
local form = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function form0(_3_0)
      local _4_ = _3_0
      local root_3f = _4_["root?"]
      do
        local flags = nil
        local function _5_()
          if root_3f then
            return "r"
          else
            return ""
          end
        end
        flags = ("Wnz" .. _5_())
        local cursor_char = current_char()
        local skip_match_3f_viml = "luaeval(\"require('conjure.extract')['skip-match?']()\")"
        local start = nil
        local function _6_()
          if (cursor_char == "(") then
            return "c"
          else
            return ""
          end
        end
        start = nvim.fn.searchpairpos("(", "", ")", (flags .. "b" .. _6_()), skip_match_3f_viml)
        local _end = nil
        local function _7_()
          if (cursor_char == ")") then
            return "c"
          else
            return ""
          end
        end
        _end = nvim.fn.searchpairpos("(", "", ")", (flags .. _7_()), skip_match_3f_viml)
        if (not nil_pos_3f(start) and not nil_pos_3f(_end)) then
          return {content = read_range(start, _end), range = {["end"] = a.update(_end, 2, a.dec), start = a.update(start, 2, a.dec)}}
        end
      end
    end
    v_23_0_0 = form0
    _0_0["form"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["form"] = v_23_0_
  form = v_23_0_
end
local word = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function word0()
      return {content = nvim.fn.expand("<cword>"), range = {["end"] = nvim.win_get_cursor(0), start = nvim.win_get_cursor(0)}}
    end
    v_23_0_0 = word0
    _0_0["word"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["word"] = v_23_0_
  word = v_23_0_
end
local file_path = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function file_path0()
      return nvim.fn.expand("%:p")
    end
    v_23_0_0 = file_path0
    _0_0["file-path"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["file-path"] = v_23_0_
  file_path = v_23_0_
end
local buf_last_line_length = nil
do
  local v_23_0_ = nil
  local function buf_last_line_length0(buf)
    return a.count(a.first(nvim.buf_get_lines(buf, a.dec(nvim.buf_line_count(buf)), -1, false)))
  end
  v_23_0_ = buf_last_line_length0
  _0_0["aniseed/locals"]["buf-last-line-length"] = v_23_0_
  buf_last_line_length = v_23_0_
end
local range = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function range0(start, _end)
      return {content = str.join("\n", nvim.buf_get_lines(0, start, _end, false)), range = {["end"] = {_end, buf_last_line_length(0)}, start = {a.inc(start), 0}}}
    end
    v_23_0_0 = range0
    _0_0["range"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["range"] = v_23_0_
  range = v_23_0_
end
local buf = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function buf0()
      return range(0, -1)
    end
    v_23_0_0 = buf0
    _0_0["buf"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_23_0_
  buf = v_23_0_
end
local getpos = nil
do
  local v_23_0_ = nil
  local function getpos0(expr)
    local _3_ = nvim.fn.getpos(expr)
    local _ = _3_[1]
    local start = _3_[2]
    local _end = _3_[3]
    local _0 = _3_[4]
    return {start, a.dec(_end)}
  end
  v_23_0_ = getpos0
  _0_0["aniseed/locals"]["getpos"] = v_23_0_
  getpos = v_23_0_
end
local selection = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function selection0(_3_0)
      local _4_ = _3_0
      local visual_3f = _4_["visual?"]
      local kind = _4_["kind"]
      do
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
        do
          local content = nvim.eval("@@")
          nvim.o.selection = sel_backup
          nvim.ex.let("@@ = g:conjure_selection_reg_backup")
          return {content = content, range = {["end"] = getpos("'>"), start = getpos("'<")}}
        end
      end
    end
    v_23_0_0 = selection0
    _0_0["selection"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["selection"] = v_23_0_
  selection = v_23_0_
end
local context = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function context0()
      local header = str.join("\n", nvim.buf_get_lines(0, 0, config.extract["context-header-lines"], false))
      return string.match(header, lang.get("context-pattern"))
    end
    v_23_0_0 = context0
    _0_0["context"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["context"] = v_23_0_
  context = v_23_0_
end
local prompt = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function prompt0(prefix)
      return nvim.fn.input((prefix or ""))
    end
    v_23_0_0 = prompt0
    _0_0["prompt"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["prompt"] = v_23_0_
  prompt = v_23_0_
end
local prompt_char = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function prompt_char0()
      return nvim.fn.nr2char(nvim.fn.getchar())
    end
    v_23_0_0 = prompt_char0
    _0_0["prompt-char"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["prompt-char"] = v_23_0_
  prompt_char = v_23_0_
end
return nil