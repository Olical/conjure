local _2afile_2a = "fnl/conjure/extract.fnl"
local _2amodule_name_2a = "conjure.extract"
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
local a, client, config, nu, nvim, searchpair, str, ts = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.aniseed.nvim.util"), autoload("conjure.aniseed.nvim"), autoload("conjure.extract.searchpair"), autoload("conjure.aniseed.string"), autoload("conjure.tree-sitter")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nu"] = nu
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["searchpair"] = searchpair
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["ts"] = ts
local function form(opts)
  if ts["enabled?"]() then
    local function _1_()
      if opts["root?"] then
        return ts["get-root"]()
      else
        return ts["get-form"]()
      end
    end
    return ts["node->table"](_1_())
  else
    return searchpair.form(opts)
  end
end
_2amodule_2a["form"] = form
local function legacy_word()
  local cword = nvim.fn.expand("<cword>")
  local line = nvim.fn.getline(".")
  local cword_index = nvim.fn.strridx(line, cword, (nvim.fn.col(".") - 1))
  local line_num = nvim.fn.line(".")
  return {content = cword, range = {start = {line_num, cword_index}, ["end"] = {line_num, (cword_index + #cword + -1)}}}
end
_2amodule_2a["legacy-word"] = legacy_word
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
_2amodule_2a["word"] = word
local function file_path()
  return nvim.fn.expand("%:p")
end
_2amodule_2a["file-path"] = file_path
local function buf_last_line_length(buf)
  return a.count(a.first(nvim.buf_get_lines(buf, a.dec(nvim.buf_line_count(buf)), -1, false)))
end
_2amodule_locals_2a["buf-last-line-length"] = buf_last_line_length
local function range(start, _end)
  return {content = str.join("\n", nvim.buf_get_lines(0, start, _end, false)), range = {start = {a.inc(start), 0}, ["end"] = {_end, buf_last_line_length(0)}}}
end
_2amodule_2a["range"] = range
local function buf()
  return range(0, -1)
end
_2amodule_2a["buf"] = buf
local function getpos(expr)
  local _let_5_ = nvim.fn.getpos(expr)
  local _ = _let_5_[1]
  local start = _let_5_[2]
  local _end = _let_5_[3]
  local _0 = _let_5_[4]
  return {start, a.dec(_end)}
end
_2amodule_locals_2a["getpos"] = getpos
local function selection(_6_)
  local _arg_7_ = _6_
  local kind = _arg_7_["kind"]
  local visual_3f = _arg_7_["visual?"]
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
_2amodule_2a["selection"] = selection
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
_2amodule_2a["context"] = context
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
_2amodule_2a["prompt"] = prompt
local function prompt_char()
  return nvim.fn.nr2char(nvim.fn.getchar())
end
_2amodule_2a["prompt-char"] = prompt_char
return _2amodule_2a