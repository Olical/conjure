-- [nfnl] Compiled from fnl/conjure/mapping.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.mapping"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, bridge, client, config, eval, extract, log, nvim, school, str, util, _ = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.school"), autoload("conjure.aniseed.string"), autoload("conjure.util"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["school"] = school
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["util"] = util
_2amodule_locals_2a["_"] = _
local buf = (_2amodule_2a).buf
local client_state_command = (_2amodule_2a)["client-state-command"]
local connect_command = (_2amodule_2a)["connect-command"]
local eval_ranged_command = (_2amodule_2a)["eval-ranged-command"]
local init = (_2amodule_2a).init
local omnifunc = (_2amodule_2a).omnifunc
local on_exit = (_2amodule_2a)["on-exit"]
local on_filetype = (_2amodule_2a)["on-filetype"]
local on_quit = (_2amodule_2a)["on-quit"]
local a0 = (_2amodule_locals_2a).a
local bridge0 = (_2amodule_locals_2a).bridge
local cfg = (_2amodule_locals_2a).cfg
local client0 = (_2amodule_locals_2a).client
local config0 = (_2amodule_locals_2a).config
local eval0 = (_2amodule_locals_2a).eval
local extract0 = (_2amodule_locals_2a).extract
local log0 = (_2amodule_locals_2a).log
local nvim0 = (_2amodule_locals_2a).nvim
local school0 = (_2amodule_locals_2a).school
local str0 = (_2amodule_locals_2a).str
local util0 = (_2amodule_locals_2a).util
local vim_repeat = (_2amodule_locals_2a)["vim-repeat"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function cfg0(k)
  return config0["get-in"]({"mapping", k})
end
_2amodule_locals_2a["cfg"] = cfg0
do local _ = {cfg0, nil} end
local function vim_repeat0(mapping)
  return ("repeat#set(\"" .. nvim0.fn.escape(mapping, "\"") .. "\", 1)")
end
_2amodule_locals_2a["vim-repeat"] = vim_repeat0
do local _ = {vim_repeat0, nil} end
local function buf0(name_suffix, mapping_suffix, handler_fn, opts)
  if mapping_suffix then
    local mapping
    if a0["string?"](mapping_suffix) then
      mapping = (cfg0("prefix") .. mapping_suffix)
    else
      mapping = a0.first(mapping_suffix)
    end
    local cmd = ("Conjure" .. name_suffix)
    local desc = (a0.get(opts, "desc") or ("Executes the " .. cmd .. " command"))
    local mode = a0.get(opts, "mode", "n")
    nvim0.create_user_command(cmd, handler_fn, a0["merge!"]({force = true, desc = desc}, a0.get(opts, "command-opts", {})))
    local function _2_()
      if (false ~= a0.get(opts, "repeat?")) then
        pcall(nvim0.fn["repeat#set"], util0["replace-termcodes"](mapping), 1)
      else
      end
      local _4_
      if ("n" == mode) then
        _4_ = util0["replace-termcodes"]("<cmd>")
      else
        _4_ = ":"
      end
      return nvim0.ex.normal_(str0.join({_4_, cmd, util0["replace-termcodes"]("<cr>")}))
    end
    return nvim0.buf_set_keymap(a0.get(opts, "buf", 0), mode, mapping, "", a0["merge!"]({silent = true, noremap = true, desc = desc, callback = _2_}, a0.get(opts, "mapping-opts", {})))
  else
    return nil
  end
end
_2amodule_2a["buf"] = buf0
do local _ = {buf0, nil} end
local function on_filetype0()
  buf0("LogSplit", cfg0("log_split"), util0["wrap-require-fn-call"]("conjure.log", "split"), {desc = "Open log in new horizontal split window"})
  buf0("LogVSplit", cfg0("log_vsplit"), util0["wrap-require-fn-call"]("conjure.log", "vsplit"), {desc = "Open log in new vertical split window"})
  buf0("LogTab", cfg0("log_tab"), util0["wrap-require-fn-call"]("conjure.log", "tab"), {desc = "Open log in new tab"})
  buf0("LogBuf", cfg0("log_buf"), util0["wrap-require-fn-call"]("conjure.log", "buf"), {desc = "Open log in new buffer"})
  buf0("LogToggle", cfg0("log_toggle"), util0["wrap-require-fn-call"]("conjure.log", "toggle"), {desc = "Toggle log buffer"})
  buf0("LogCloseVisible", cfg0("log_close_visible"), util0["wrap-require-fn-call"]("conjure.log", "close-visible"), {desc = "Close all visible log windows"})
  buf0("LogResetSoft", cfg0("log_reset_soft"), util0["wrap-require-fn-call"]("conjure.log", "reset-soft"), {desc = "Soft reset log"})
  buf0("LogResetHard", cfg0("log_reset_hard"), util0["wrap-require-fn-call"]("conjure.log", "reset-hard"), {desc = "Hard reset log"})
  buf0("LogJumpToLatest", cfg0("log_jump_to_latest"), util0["wrap-require-fn-call"]("conjure.log", "jump-to-latest"), {desc = "Jump to latest part of log"})
  local function _7_()
    nvim0.o.opfunc = "ConjureEvalMotionOpFunc"
    local function _8_()
      return nvim0.feedkeys("g@", "m", false)
    end
    return client0.schedule(_8_)
  end
  buf0("EvalMotion", cfg0("eval_motion"), _7_, {desc = "Evaluate motion"})
  buf0("EvalCurrentForm", cfg0("eval_current_form"), util0["wrap-require-fn-call"]("conjure.eval", "current-form"), {desc = "Evaluate current form"})
  buf0("EvalCommentCurrentForm", cfg0("eval_comment_current_form"), util0["wrap-require-fn-call"]("conjure.eval", "comment-current-form"), {desc = "Evaluate current form and comment result"})
  buf0("EvalRootForm", cfg0("eval_root_form"), util0["wrap-require-fn-call"]("conjure.eval", "root-form"), {desc = "Evaluate root form"})
  buf0("EvalCommentRootForm", cfg0("eval_comment_root_form"), util0["wrap-require-fn-call"]("conjure.eval", "comment-root-form"), {desc = "Evaluate root form and comment result"})
  buf0("EvalWord", cfg0("eval_word"), util0["wrap-require-fn-call"]("conjure.eval", "word"), {desc = "Evaluate word"})
  buf0("EvalCommentWord", cfg0("eval_comment_word"), util0["wrap-require-fn-call"]("conjure.eval", "comment-word"), {desc = "Evaluate word and comment result"})
  buf0("EvalReplaceForm", cfg0("eval_replace_form"), util0["wrap-require-fn-call"]("conjure.eval", "replace-form"), {desc = "Evaluate form and replace with result"})
  local function _9_()
    return client0.schedule(eval0["marked-form"])
  end
  buf0("EvalMarkedForm", cfg0("eval_marked_form"), _9_, {desc = "Evaluate marked form", ["repeat?"] = false})
  buf0("EvalFile", cfg0("eval_file"), util0["wrap-require-fn-call"]("conjure.eval", "file"), {desc = "Evaluate file"})
  buf0("EvalBuf", cfg0("eval_buf"), util0["wrap-require-fn-call"]("conjure.eval", "buf"), {desc = "Evaluate buffer"})
  buf0("EvalPrevious", cfg0("eval_previous"), util0["wrap-require-fn-call"]("conjure.eval", "previous"), {desc = "Evaluate previous evaluation"})
  buf0("EvalVisual", cfg0("eval_visual"), util0["wrap-require-fn-call"]("conjure.eval", "selection"), {desc = "Evaluate visual select", mode = "v", ["command-opts"] = {range = true}})
  buf0("DocWord", cfg0("doc_word"), util0["wrap-require-fn-call"]("conjure.eval", "doc-word"), {desc = "Get documentation under cursor"})
  buf0("DefWord", cfg0("def_word"), util0["wrap-require-fn-call"]("conjure.eval", "def-word"), {desc = "Get definition under cursor"})
  do
    local fn_name = config0["get-in"]({"completion", "omnifunc"})
    if fn_name then
      nvim0.ex.setlocal(("omnifunc=" .. fn_name))
    else
    end
  end
  return client0["optional-call"]("on-filetype")
end
_2amodule_2a["on-filetype"] = on_filetype0
do local _ = {on_filetype0, nil} end
local function on_exit0()
  local function _11_()
    return client0["optional-call"]("on-exit")
  end
  return client0["each-loaded-client"](_11_)
end
_2amodule_2a["on-exit"] = on_exit0
do local _ = {on_exit0, nil} end
local function on_quit0()
  return log0["close-hud"]()
end
_2amodule_2a["on-quit"] = on_quit
do local _ = {on_quit, nil} end
local function init(filetypes)
  nvim.ex.augroup("conjure_init_filetypes")
  nvim.ex.autocmd_()
  if (true == config["get-in"]({"mapping", "enable_ft_mappings"})) then
    nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
    local function _12_(_241)
      return (_241 == nvim.bo.filetype)
    end
    if a.some(_12_, filetypes) then
      vim.schedule(on_filetype)
    else
    end
  else
  end
  nvim0.ex.autocmd("CursorMoved", "*", bridge0["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim0.ex.autocmd("CursorMovedI", "*", bridge0["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim0.ex.autocmd("CursorMoved", "*", bridge0["viml->lua"]("conjure.inline", "clear", {}))
  nvim0.ex.autocmd("CursorMovedI", "*", bridge0["viml->lua"]("conjure.inline", "clear", {}))
  nvim0.ex.autocmd("VimLeavePre", "*", bridge0["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
  nvim0.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-exit" .. "']()"))
  nvim0.ex.autocmd("QuitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-quit" .. "']()"))
  return nvim0.ex.augroup("END")
end
_2amodule_2a["init"] = init0
do local _ = {init0, nil} end
local function eval_ranged_command0(start, _end, code)
  if ("" == code) then
    return eval0.range(a0.dec(start), _end)
  else
    return eval0.command(code)
  end
end
_2amodule_2a["eval-ranged-command"] = eval_ranged_command0
do local _ = {eval_ranged_command0, nil} end
local function connect_command0(...)
  local args = {...}
  local function _17_(...)
    if (1 == a.count(args)) then
      local host, port = string.match(a.first(args), "([a-zA-Z%d\\.-]+):(%d+)$")
      if (host and port) then
        return {host = host, port = port}
      else
        return {port = a0.first(args)}
      end
    else
      return {host = a0.first(args), port = a0.second(args)}
    end
  end
  return client.call("connect", _17_(...))
end
_2amodule_2a["connect-command"] = connect_command0
do local _ = {connect_command0, nil} end
local function client_state_command0(state_key)
  if a0["empty?"](state_key) then
    return a0.println(client0["state-key"]())
  else
    return client0["set-state-key!"](state_key)
  end
end
_2amodule_2a["client-state-command"] = client_state_command0
do local _ = {client_state_command0, nil} end
local function omnifunc0(find_start_3f, base)
  if find_start_3f then
    local _let_19_ = nvim.win_get_cursor(0)
    local row = _let_19_[1]
    local col = _let_19_[2]
    local _let_20_ = nvim.buf_get_lines(0, a.dec(row), row, false)
    local line = _let_20_[1]
    return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
  else
    return eval0["completions-sync"](base)
  end
end
_2amodule_2a["omnifunc"] = omnifunc
do local _ = {omnifunc, nil} end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotionOpFunc(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
local function _22_(_241)
  return eval_ranged_command((_241).line1, (_241).line2, (_241).args)
end
nvim.create_user_command("ConjureEval", _22_, {nargs = "?", range = true})
local function _23_(_241)
  return connect_command(unpack((_241).fargs))
end
nvim.create_user_command("ConjureConnect", _23_, {nargs = "*", range = true, complete = "file"})
local function _24_(_241)
  return client_state_command((_241).args)
end
nvim.create_user_command("ConjureClientState", _24_, {nargs = "?"})
local function _25_()
  return school.start()
end
nvim.create_user_command("ConjureSchool", _25_, {})
return _2amodule_2a