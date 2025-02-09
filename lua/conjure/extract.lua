-- [nfnl] Compiled from fnl/conjure/extract.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local nu = autoload("conjure.aniseed.nvim.util")
local str = autoload("conjure.aniseed.string")
local config = autoload("conjure.config")
local client = autoload("conjure.client")
local ts = autoload("conjure.tree-sitter")
local searchpair = autoload("conjure.extract.searchpair")
local function form(opts)
  if ts["enabled?"]() then
    local function _2_()
      if opts["root?"] then
        return ts["get-root"]()
      else
        return ts["get-form"]()
      end
    end
    return ts["node->table"](_2_())
  else
    return searchpair.form(opts)
  end
end
local function legacy_word()
  local cword = nvim.fn.expand("<cword>")
  local line = nvim.fn.getline(".")
  local cword_index = nvim.fn.strridx(line, cword, (nvim.fn.col(".") - 1))
  local line_num = nvim.fn.line(".")
  return {content = cword, range = {start = {line_num, cword_index}, ["end"] = {line_num, (cword_index + #cword + -1)}}}
end
local function word()
  if ts["enabled?"]() then
    local node = ts["get-leaf"]()
    if node then
      return {range = ts.range(node), content = ts["node->str"](node)}
    else
      return {range = nil, content = nil}
    end
  else
    return legacy_word()
  end
end
local function file_path()
  return nvim.fn.expand("%:p")
end
local function buf_last_line_length(buf)
  return a.count(a.first(nvim.buf_get_lines(buf, a.dec(nvim.buf_line_count(buf)), -1, false)))
end
local function range(start, _end)
  return {content = str.join("\n", nvim.buf_get_lines(0, start, _end, false)), range = {start = {a.inc(start), 0}, ["end"] = {_end, buf_last_line_length(0)}}}
end
local function buf()
  return range(0, -1)
end
local function getpos(expr)
  local _let_6_ = nvim.fn.getpos(expr)
  local _ = _let_6_[1]
  local start = _let_6_[2]
  local _end = _let_6_[3]
  local _0 = _let_6_[4]
  return {start, a.dec(_end)}
end
local function selection(_7_)
  local kind = _7_["kind"]
  local visual_3f = _7_["visual?"]
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
  return {content = content, range = {start = getpos("'<"), ["end"] = getpos("'>")}}
end
local function context()
  local pat = client.get("context-pattern")
  local f
  if pat then
    local function _9_(_241)
      return string.match(_241, pat)
    end
    f = _9_
  else
    f = client.get("context")
  end
  if f then
    return f(str.join("\n", nvim.buf_get_lines(0, 0, config["get-in"]({"extract", "context_header_lines"}), false)))
  else
    return nil
  end
end
local function prompt(prefix)
  local ok_3f, val = nil, nil
  local function _12_()
    return nvim.fn.input((prefix or ""))
  end
  ok_3f, val = pcall(_12_)
  if ok_3f then
    return val
  else
    return nil
  end
end
local function prompt_char()
  return nvim.fn.nr2char(nvim.fn.getchar())
end
return {form = form, ["legacy-word"] = legacy_word, word = word, ["file-path"] = file_path, range = range, buf = buf, selection = selection, context = context, prompt = prompt, ["prompt-char"] = prompt_char}
