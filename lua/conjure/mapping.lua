-- [nfnl] Compiled from fnl/conjure/mapping.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local client = autoload("conjure.client")
local eval = autoload("conjure.eval")
local inline = autoload("conjure.inline")
local school = autoload("conjure.school")
local util = autoload("conjure.util")
local function cfg(k)
  return config["get-in"]({"mapping", k})
end
local function buf(name_suffix, mapping_suffix, handler_fn, opts)
  if mapping_suffix then
    local mapping
    if a["string?"](mapping_suffix) then
      mapping = (cfg("prefix") .. mapping_suffix)
    else
      mapping = a.first(mapping_suffix)
    end
    local cmd = ("Conjure" .. name_suffix)
    local desc = (a.get(opts, "desc") or ("Executes the " .. cmd .. " command"))
    local mode = a.get(opts, "mode", "n")
    vim.api.nvim_buf_create_user_command(a.get(opts, "buf", 0), cmd, handler_fn, a["merge!"]({force = true, desc = desc}, a.get(opts, "command-opts", {})))
    local function _3_()
      if (false ~= a.get(opts, "repeat?")) then
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
    return vim.api.nvim_buf_set_keymap(a.get(opts, "buf", 0), mode, mapping, "", a["merge!"]({silent = true, noremap = true, desc = desc, callback = _3_}, a.get(opts, "mapping-opts", {})))
  else
    return nil
  end
end
local function on_filetype()
  buf("LogSplit", cfg("log_split"), util["wrap-require-fn-call"]("conjure.log", "split"), {desc = "Open log in new horizontal split window"})
  buf("LogVSplit", cfg("log_vsplit"), util["wrap-require-fn-call"]("conjure.log", "vsplit"), {desc = "Open log in new vertical split window"})
  buf("LogTab", cfg("log_tab"), util["wrap-require-fn-call"]("conjure.log", "tab"), {desc = "Open log in new tab"})
  buf("LogBuf", cfg("log_buf"), util["wrap-require-fn-call"]("conjure.log", "buf"), {desc = "Open log in new buffer"})
  buf("LogToggle", cfg("log_toggle"), util["wrap-require-fn-call"]("conjure.log", "toggle"), {desc = "Toggle log buffer"})
  buf("LogCloseVisible", cfg("log_close_visible"), util["wrap-require-fn-call"]("conjure.log", "close-visible"), {desc = "Close all visible log windows"})
  buf("LogResetSoft", cfg("log_reset_soft"), util["wrap-require-fn-call"]("conjure.log", "reset-soft"), {desc = "Soft reset log"})
  buf("LogResetHard", cfg("log_reset_hard"), util["wrap-require-fn-call"]("conjure.log", "reset-hard"), {desc = "Hard reset log"})
  buf("LogJumpToLatest", cfg("log_jump_to_latest"), util["wrap-require-fn-call"]("conjure.log", "jump-to-latest"), {desc = "Jump to latest part of log"})
  local function _8_()
    vim.o.opfunc = "ConjureEvalMotionOpFunc"
    local function _9_()
      return vim.api.nvim_feedkeys("g@", "m", false)
    end
    return client.schedule(_9_)
  end
  buf("EvalMotion", cfg("eval_motion"), _8_, {desc = "Evaluate motion"})
  buf("EvalCurrentForm", cfg("eval_current_form"), util["wrap-require-fn-call"]("conjure.eval", "current-form"), {desc = "Evaluate current form"})
  buf("EvalCommentCurrentForm", cfg("eval_comment_current_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-current-form"), {desc = "Evaluate current form and comment result"})
  buf("EvalRootForm", cfg("eval_root_form"), util["wrap-require-fn-call"]("conjure.eval", "root-form"), {desc = "Evaluate root form"})
  buf("EvalCommentRootForm", cfg("eval_comment_root_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-root-form"), {desc = "Evaluate root form and comment result"})
  buf("EvalWord", cfg("eval_word"), util["wrap-require-fn-call"]("conjure.eval", "word"), {desc = "Evaluate word"})
  buf("EvalCommentWord", cfg("eval_comment_word"), util["wrap-require-fn-call"]("conjure.eval", "comment-word"), {desc = "Evaluate word and comment result"})
  buf("EvalReplaceForm", cfg("eval_replace_form"), util["wrap-require-fn-call"]("conjure.eval", "replace-form"), {desc = "Evaluate form and replace with result"})
  local function _10_()
    return client.schedule(eval["marked-form"])
  end
  buf("EvalMarkedForm", cfg("eval_marked_form"), _10_, {desc = "Evaluate marked form", ["repeat?"] = false})
  buf("EvalFile", cfg("eval_file"), util["wrap-require-fn-call"]("conjure.eval", "file"), {desc = "Evaluate file"})
  buf("EvalBuf", cfg("eval_buf"), util["wrap-require-fn-call"]("conjure.eval", "buf"), {desc = "Evaluate buffer"})
  buf("EvalPrevious", cfg("eval_previous"), util["wrap-require-fn-call"]("conjure.eval", "previous"), {desc = "Evaluate previous evaluation"})
  buf("EvalVisual", cfg("eval_visual"), util["wrap-require-fn-call"]("conjure.eval", "selection"), {desc = "Evaluate visual select", mode = "v", ["command-opts"] = {range = true}})
  buf("DocWord", cfg("doc_word"), util["wrap-require-fn-call"]("conjure.eval", "doc-word"), {desc = "Get documentation under cursor"})
  buf("DefWord", cfg("def_word"), util["wrap-require-fn-call"]("conjure.eval", "def-word"), {desc = "Get definition under cursor"})
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
local function on_exit()
  local function _13_()
    return client["optional-call"]("on-exit")
  end
  return client["each-loaded-client"](_13_)
end
local function on_quit()
  return log["close-hud"]()
end
local function autocmd_callback(f)
  local function _14_(ev)
    f(ev)
    return nil
  end
  return _14_
end
local function init(filetypes)
  local group = vim.api.nvim_create_augroup("conjure_init_filetypes", {})
  if (true == config["get-in"]({"mapping", "enable_ft_mappings"})) then
    vim.api.nvim_create_autocmd("FileType", {group = group, pattern = filetypes, callback = autocmd_callback(on_filetype)})
    local function _15_(_241)
      return (_241 == vim.bo.filetype)
    end
    if a.some(_15_, filetypes) then
      vim.schedule(on_filetype)
    else
    end
  else
  end
  vim.api.nvim_create_autocmd("CursorMoved", {group = group, pattern = "*", callback = autocmd_callback(log["close-hud-passive"])})
  vim.api.nvim_create_autocmd("CursorMovedI", {group = group, pattern = "*", callback = autocmd_callback(log["close-hud-passive"])})
  vim.api.nvim_create_autocmd("CursorMoved", {group = group, pattern = "*", callback = autocmd_callback(inline.clear)})
  vim.api.nvim_create_autocmd("CursorMovedI", {group = group, pattern = "*", callback = autocmd_callback(inline.clear)})
  vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = autocmd_callback(log["clear-close-hud-passive-timer"])})
  vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = autocmd_callback(on_exit)})
  return vim.api.nvim_create_autocmd("QuitPre", {group = group, pattern = "*", callback = autocmd_callback(on_quit)})
end
local function eval_ranged_command(start, _end, code)
  if ("" == code) then
    return eval.range(a.dec(start), _end)
  else
    return eval.command(code)
  end
end
local function connect_command(...)
  local args = {...}
  local function _20_(...)
    if (1 == a.count(args)) then
      local host, port = string.match(a.first(args), "([a-zA-Z%d\\.-]+):(%d+)$")
      if (host and port) then
        return {host = host, port = port}
      else
        return {port = a.first(args)}
      end
    else
      return {host = a.first(args), port = a.second(args)}
    end
  end
  return client.call("connect", _20_(...))
end
local function client_state_command(state_key)
  if a["empty?"](state_key) then
    return a.println(client["state-key"]())
  else
    return client["set-state-key!"](state_key)
  end
end
local function omnifunc(find_start_3f, base)
  if find_start_3f then
    local _let_22_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_22_[1]
    local col = _let_22_[2]
    local _let_23_ = vim.api.nvim_buf_get_lines(0, a.dec(row), row, false)
    local line = _let_23_[1]
    return (col - a.count(vim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
  else
    return eval["completions-sync"](base)
  end
end
vim.api.nvim_command(str.join("\n", {"function! ConjureEvalMotionOpFunc(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
vim.api.nvim_command(str.join("\n", {"function! ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
local function _25_(_241)
  return eval_ranged_command(_241.line1, _241.line2, _241.args)
end
vim.api.nvim_create_user_command("ConjureEval", _25_, {nargs = "?", range = true})
local function _26_(_241)
  return connect_command(unpack(_241.fargs))
end
vim.api.nvim_create_user_command("ConjureConnect", _26_, {nargs = "*", range = true, complete = "file"})
local function _27_(_241)
  return client_state_command(_241.args)
end
vim.api.nvim_create_user_command("ConjureClientState", _27_, {nargs = "?"})
local function _28_()
  return school.start()
end
vim.api.nvim_create_user_command("ConjureSchool", _28_, {})
return {buf = buf, ["on-filetype"] = on_filetype, ["on-exit"] = on_exit, ["on-quit"] = on_quit, init = init, ["eval-ranged-command"] = eval_ranged_command, ["connect-command"] = connect_command, ["client-state-command"] = client_state_command, omnifunc = omnifunc}
