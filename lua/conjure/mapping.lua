-- [nfnl] Compiled from fnl/conjure/mapping.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local client = autoload("conjure.client")
local eval = autoload("conjure.eval")
local inline = autoload("conjure.inline")
local school = autoload("conjure.school")
local util = autoload("conjure.util")
local M = define("conjure.mapping", {})
local function cfg(k)
  return config["get-in"]({"mapping", k})
end
M.buf = function(name_suffix, mapping_suffix, handler_fn, opts)
  if mapping_suffix then
    local mapping
    if core["string?"](mapping_suffix) then
      mapping = (cfg("prefix") .. mapping_suffix)
    else
      mapping = core.first(mapping_suffix)
    end
    local cmd = ("Conjure" .. name_suffix)
    local desc = (core.get(opts, "desc") or ("Executes the " .. cmd .. " command"))
    local mode = core.get(opts, "mode", "n")
    vim.api.nvim_buf_create_user_command(core.get(opts, "buf", 0), cmd, handler_fn, core["merge!"]({force = true, desc = desc}, core.get(opts, "command-opts", {})))
    local function _3_()
      if (false ~= core.get(opts, "repeat?")) then
        pcall(vim.fn["repeat#set"], util["replace-termcodes"](mapping), 1)
      else
      end
      local _5_
      if ("n" == mode) then
        _5_ = util["replace-termcodes"]("<cmd>")
      else
        _5_ = ":"
      end
      return vim.api.nvim_command(str.join({"normal! ", _5_, cmd, util["replace-termcodes"]("<cr>")}))
    end
    return vim.api.nvim_buf_set_keymap(core.get(opts, "buf", 0), mode, mapping, "", core["merge!"]({silent = true, noremap = true, desc = desc, callback = _3_}, core.get(opts, "mapping-opts", {})))
  else
    return nil
  end
end
M["on-filetype"] = function()
  M.buf("LogSplit", cfg("log_split"), util["wrap-require-fn-call"]("conjure.log", "split"), {desc = "Open log in new horizontal split window"})
  M.buf("LogVSplit", cfg("log_vsplit"), util["wrap-require-fn-call"]("conjure.log", "vsplit"), {desc = "Open log in new vertical split window"})
  M.buf("LogTab", cfg("log_tab"), util["wrap-require-fn-call"]("conjure.log", "tab"), {desc = "Open log in new tab"})
  M.buf("LogBuf", cfg("log_buf"), util["wrap-require-fn-call"]("conjure.log", "buf"), {desc = "Open log in new buffer"})
  M.buf("LogToggle", cfg("log_toggle"), util["wrap-require-fn-call"]("conjure.log", "toggle"), {desc = "Toggle log buffer"})
  M.buf("LogCloseVisible", cfg("log_close_visible"), util["wrap-require-fn-call"]("conjure.log", "close-visible"), {desc = "Close all visible log windows"})
  M.buf("LogResetSoft", cfg("log_reset_soft"), util["wrap-require-fn-call"]("conjure.log", "reset-soft"), {desc = "Soft reset log"})
  M.buf("LogResetHard", cfg("log_reset_hard"), util["wrap-require-fn-call"]("conjure.log", "reset-hard"), {desc = "Hard reset log"})
  M.buf("LogJumpToLatest", cfg("log_jump_to_latest"), util["wrap-require-fn-call"]("conjure.log", "jump-to-latest"), {desc = "Jump to latest part of log"})
  local function _8_()
    vim.o.opfunc = "ConjureEvalMotionOpFunc"
    local function _9_()
      return vim.api.nvim_feedkeys("g@", "m", false)
    end
    return client.schedule(_9_)
  end
  M.buf("EvalMotion", cfg("eval_motion"), _8_, {desc = "Evaluate motion"})
  M.buf("EvalCurrentForm", cfg("eval_current_form"), util["wrap-require-fn-call"]("conjure.eval", "current-form"), {desc = "Evaluate current form"})
  M.buf("EvalCommentCurrentForm", cfg("eval_comment_current_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-current-form"), {desc = "Evaluate current form and comment result"})
  M.buf("EvalRootForm", cfg("eval_root_form"), util["wrap-require-fn-call"]("conjure.eval", "root-form"), {desc = "Evaluate root form"})
  M.buf("EvalCommentRootForm", cfg("eval_comment_root_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-root-form"), {desc = "Evaluate root form and comment result"})
  M.buf("EvalWord", cfg("eval_word"), util["wrap-require-fn-call"]("conjure.eval", "word"), {desc = "Evaluate word"})
  M.buf("EvalCommentWord", cfg("eval_comment_word"), util["wrap-require-fn-call"]("conjure.eval", "comment-word"), {desc = "Evaluate word and comment result"})
  M.buf("EvalReplaceForm", cfg("eval_replace_form"), util["wrap-require-fn-call"]("conjure.eval", "replace-form"), {desc = "Evaluate form and replace with result"})
  local function _10_()
    return client.schedule(eval["marked-form"])
  end
  M.buf("EvalMarkedForm", cfg("eval_marked_form"), _10_, {desc = "Evaluate marked form", ["repeat?"] = false})
  M.buf("EvalFile", cfg("eval_file"), util["wrap-require-fn-call"]("conjure.eval", "file"), {desc = "Evaluate file"})
  M.buf("EvalBuf", cfg("eval_buf"), util["wrap-require-fn-call"]("conjure.eval", "buf"), {desc = "Evaluate buffer"})
  M.buf("EvalPrevious", cfg("eval_previous"), util["wrap-require-fn-call"]("conjure.eval", "previous"), {desc = "Evaluate previous evaluation"})
  M.buf("EvalVisual", cfg("eval_visual"), util["wrap-require-fn-call"]("conjure.eval", "selection"), {desc = "Evaluate visual select", mode = "v", ["command-opts"] = {range = true}})
  M.buf("DocWord", cfg("doc_word"), util["wrap-require-fn-call"]("conjure.eval", "doc-word"), {desc = "Get documentation under cursor"})
  M.buf("DefWord", cfg("def_word"), util["wrap-require-fn-call"]("conjure.eval", "def-word"), {desc = "Get definition under cursor"})
  if ("function" == type(client.get("completions"))) then
    local fn_name = config["get-in"]({"completion", "omnifunc"})
    if fn_name then
      vim.api.nvim_command(("setlocal omnifunc=" .. fn_name))
    else
    end
  else
  end
  return client["optional-call"]("on-filetype")
end
M["on-exit"] = function()
  local function _13_()
    return client["optional-call"]("on-exit")
  end
  return client["each-loaded-client"](_13_)
end
M["on-quit"] = function()
  return log["close-hud"]()
end
local function autocmd_callback(f)
  local function _14_(ev)
    f(ev)
    return nil
  end
  return _14_
end
M.init = function(filetypes)
  local group = vim.api.nvim_create_augroup("conjure_init_filetypes", {})
  if (true == config["get-in"]({"mapping", "enable_ft_mappings"})) then
    vim.api.nvim_create_autocmd("FileType", {group = group, pattern = filetypes, callback = autocmd_callback(M["on-filetype"])})
    local function _15_(_241)
      return (_241 == vim.bo.filetype)
    end
    if core.some(_15_, filetypes) then
      vim.schedule(M["on-filetype"])
    else
    end
  else
  end
  vim.api.nvim_create_autocmd("CursorMoved", {group = group, pattern = "*", callback = autocmd_callback(log["close-hud-passive"])})
  vim.api.nvim_create_autocmd("CursorMovedI", {group = group, pattern = "*", callback = autocmd_callback(log["close-hud-passive"])})
  vim.api.nvim_create_autocmd("CursorMoved", {group = group, pattern = "*", callback = autocmd_callback(inline.clear)})
  vim.api.nvim_create_autocmd("CursorMovedI", {group = group, pattern = "*", callback = autocmd_callback(inline.clear)})
  vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = autocmd_callback(log["clear-close-hud-passive-timer"])})
  vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = autocmd_callback(M["on-exit"])})
  return vim.api.nvim_create_autocmd("QuitPre", {group = group, pattern = "*", callback = autocmd_callback(M["on-quit"])})
end
M["eval-ranged-command"] = function(start, _end, code)
  if ("" == code) then
    return eval.range(core.dec(start), _end)
  else
    return eval.command(code)
  end
end
M["connect-command"] = function(...)
  local args = {...}
  local function _20_(...)
    if (1 == core.count(args)) then
      local host, port = string.match(core.first(args), "([a-zA-Z%d\\.-]+):(%d+)$")
      if (host and port) then
        return {host = host, port = port}
      else
        return {port = core.first(args)}
      end
    else
      return {host = core.first(args), port = core.second(args)}
    end
  end
  return client.call("connect", _20_(...))
end
M["client-state-command"] = function(state_key)
  if core["empty?"](state_key) then
    return core.println(client["state-key"]())
  else
    return client["set-state-key!"](state_key)
  end
end
M.omnifunc = function(find_start_3f, base)
  if find_start_3f then
    local _let_22_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_22_[1]
    local col = _let_22_[2]
    local _let_23_ = vim.api.nvim_buf_get_lines(0, core.dec(row), row, false)
    local line = _let_23_[1]
    return (col - core.count(vim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
  else
    return eval["completions-sync"](base)
  end
end
vim.api.nvim_command(str.join("\n", {"function! ConjureEvalMotionOpFunc(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
vim.api.nvim_command(str.join("\n", {"function! ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
local function _25_(_241)
  return M["eval-ranged-command"](_241.line1, _241.line2, _241.args)
end
vim.api.nvim_create_user_command("ConjureEval", _25_, {nargs = "?", range = true})
local function _26_(_241)
  return M["connect-command"](unpack(_241.fargs))
end
vim.api.nvim_create_user_command("ConjureConnect", _26_, {nargs = "*", range = true, complete = "file"})
local function _27_(_241)
  return M["client-state-command"](_241.args)
end
vim.api.nvim_create_user_command("ConjureClientState", _27_, {nargs = "?"})
local function _28_()
  return school.start()
end
vim.api.nvim_create_user_command("ConjureSchool", _28_, {})
return M
