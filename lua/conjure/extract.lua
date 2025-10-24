-- [nfnl] fnl/conjure/extract.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local config = autoload("conjure.config")
local client = autoload("conjure.client")
local ts = autoload("conjure.tree-sitter")
local searchpair = autoload("conjure.extract.searchpair")
local M = define("conjure.extract")
M.form = function(opts)
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
M["legacy-word"] = function()
  local cword = vim.fn.expand("<cword>")
  local line = vim.fn.getline(".")
  local cword_index = vim.fn.strridx(line, cword, (vim.fn.col(".") - 1))
  local line_num = vim.fn.line(".")
  return {content = cword, range = {start = {line_num, cword_index}, ["end"] = {line_num, (cword_index + #cword + -1)}}}
end
M.word = function()
  if ts["enabled?"]() then
    local node = ts["get-leaf"]()
    if node then
      return {range = ts.range(node), content = ts["node->str"](node)}
    else
      return {range = nil, content = nil}
    end
  else
    return M["legacy-word"]()
  end
end
M["file-path"] = function()
  return vim.fn.expand("%:p")
end
local function buf_last_line_length(buf)
  return core.count(core.first(vim.api.nvim_buf_get_lines(buf, core.dec(vim.api.nvim_buf_line_count(buf)), -1, false)))
end
M.range = function(start, _end)
  return {content = str.join("\n", vim.api.nvim_buf_get_lines(0, start, _end, false)), range = {start = {core.inc(start), 0}, ["end"] = {_end, buf_last_line_length(0)}}}
end
M.buf = function()
  return M.range(0, -1)
end
local function getpos(expr)
  local _let_6_ = vim.fn.getpos(expr)
  local _ = _let_6_[1]
  local start = _let_6_[2]
  local _end = _let_6_[3]
  local _0 = _let_6_[4]
  return {start, core.dec(_end)}
end
local function nu_normal(keys)
  return vim.cmd(("silent exe \"normal! " .. keys .. "\""))
end
M.selection = function(_7_)
  local kind = _7_.kind
  local visual_3f = _7_["visual?"]
  local sel_backup = vim.o.selection
  vim.cmd("let g:conjure_selection_reg_backup = @@")
  vim.o.selection = "inclusive"
  if visual_3f then
    nu_normal(("`<" .. kind .. "`>y"))
  elseif (kind == "line") then
    nu_normal("'[V']y")
  elseif (kind == "block") then
    nu_normal("`[\22`]y")
  else
    nu_normal("`[v`]y")
  end
  local content = vim.api.nvim_eval("@@")
  vim.o.selection = sel_backup
  vim.cmd("let @@ = g:conjure_selection_reg_backup")
  return {content = content, range = {start = getpos("'<"), ["end"] = getpos("'>")}}
end
M.context = function()
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
    return f(str.join("\n", vim.api.nvim_buf_get_lines(0, 0, config["get-in"]({"extract", "context_header_lines"}), false)))
  else
    return nil
  end
end
M.prompt = function(prefix)
  local ok_3f, val
  local function _12_()
    return vim.fn.input((prefix or ""))
  end
  ok_3f, val = pcall(_12_)
  if ok_3f then
    return val
  else
    return nil
  end
end
M["prompt-char"] = function()
  return vim.fn.nr2char(vim.fn.getchar())
end
return M
