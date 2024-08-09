-- [nfnl] Compiled from fnl/conjure/mapping.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.mapping"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
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
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function cfg(k)
  return config["get-in"]({"mapping", k})
end
_2amodule_locals_2a["cfg"] = cfg
do local _ = {cfg, nil} end
local function vim_repeat(mapping)
  return ("repeat#set(\"" .. nvim.fn.escape(mapping, "\"") .. "\", 1)")
end
_2amodule_locals_2a["vim-repeat"] = vim_repeat
do local _ = {vim_repeat, nil} end
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
    nvim.create_user_command(cmd, handler_fn, a["merge!"]({force = true, desc = desc}, a.get(opts, "command-opts", {})))
    local function _2_()
      if (false ~= a.get(opts, "repeat?")) then
        pcall(nvim.fn["repeat#set"], util["replace-termcodes"](mapping), 1)
      else
      end
      local _4_
      if ("n" == mode) then
        _4_ = util["replace-termcodes"]("<cmd>")
      else
        _4_ = ":"
      end
      return nvim.ex.normal_(str.join({_4_, cmd, util["replace-termcodes"]("<cr>")}))
    end
    return nvim.buf_set_keymap(a.get(opts, "buf", 0), mode, mapping, "", a["merge!"]({silent = true, noremap = true, desc = desc, callback = _2_}, a.get(opts, "mapping-opts", {})))
  else
    return nil
  end
end
_2amodule_2a["buf"] = buf
do local _ = {buf, nil} end
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
  local function _7_()
    nvim.o.opfunc = "ConjureEvalMotionOpFunc"
    local function _8_()
      return nvim.feedkeys("g@", "m", false)
    end
    return client.schedule(_8_)
  end
  buf("EvalMotion", cfg("eval_motion"), _7_, {desc = "Evaluate motion"})
  buf("EvalCurrentForm", cfg("eval_current_form"), util["wrap-require-fn-call"]("conjure.eval", "current-form"), {desc = "Evaluate current form"})
  buf("EvalCommentCurrentForm", cfg("eval_comment_current_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-current-form"), {desc = "Evaluate current form and comment result"})
  buf("EvalRootForm", cfg("eval_root_form"), util["wrap-require-fn-call"]("conjure.eval", "root-form"), {desc = "Evaluate root form"})
  buf("EvalCommentRootForm", cfg("eval_comment_root_form"), util["wrap-require-fn-call"]("conjure.eval", "comment-root-form"), {desc = "Evaluate root form and comment result"})
  buf("EvalWord", cfg("eval_word"), util["wrap-require-fn-call"]("conjure.eval", "word"), {desc = "Evaluate word"})
  buf("EvalCommentWord", cfg("eval_comment_word"), util["wrap-require-fn-call"]("conjure.eval", "comment-word"), {desc = "Evaluate word and comment result"})
  buf("EvalReplaceForm", cfg("eval_replace_form"), util["wrap-require-fn-call"]("conjure.eval", "replace-form"), {desc = "Evaluate form and replace with result"})
  local function _9_()
    return client.schedule(eval["marked-form"])
  end
  buf("EvalMarkedForm", cfg("eval_marked_form"), _9_, {desc = "Evaluate marked form", ["repeat?"] = false})
  buf("EvalFile", cfg("eval_file"), util["wrap-require-fn-call"]("conjure.eval", "file"), {desc = "Evaluate file"})
  buf("EvalBuf", cfg("eval_buf"), util["wrap-require-fn-call"]("conjure.eval", "buf"), {desc = "Evaluate buffer"})
  buf("EvalPrevious", cfg("eval_previous"), util["wrap-require-fn-call"]("conjure.eval", "previous"), {desc = "Evaluate previous evaluation"})
  buf("EvalVisual", cfg("eval_visual"), util["wrap-require-fn-call"]("conjure.eval", "selection"), {desc = "Evaluate visual select", mode = "v", ["command-opts"] = {range = true}})
  buf("DocWord", cfg("doc_word"), util["wrap-require-fn-call"]("conjure.eval", "doc-word"), {desc = "Get documentation under cursor"})
  buf("DefWord", cfg("def_word"), util["wrap-require-fn-call"]("conjure.eval", "def-word"), {desc = "Get definition under cursor"})
  do
    local fn_name = config["get-in"]({"completion", "omnifunc"})
    if fn_name then
      nvim.ex.setlocal(("omnifunc=" .. fn_name))
    else
    end
  end
  return client["optional-call"]("on-filetype")
end
_2amodule_2a["on-filetype"] = on_filetype
do local _ = {on_filetype, nil} end
local function on_exit()
  local function _11_()
    return client["optional-call"]("on-exit")
  end
  return client["each-loaded-client"](_11_)
end
_2amodule_2a["on-exit"] = on_exit
do local _ = {on_exit, nil} end
local function on_quit()
  return log["close-hud"]()
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
  nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
  nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
  nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
  nvim.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-exit" .. "']()"))
  nvim.ex.autocmd("QuitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-quit" .. "']()"))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init"] = init
do local _ = {init, nil} end
local function eval_ranged_command(start, _end, code)
  if ("" == code) then
    return eval.range(a.dec(start), _end)
  else
    return eval.command(code)
  end
end
_2amodule_2a["eval-ranged-command"] = eval_ranged_command
do local _ = {eval_ranged_command, nil} end
local function connect_command(...)
  local args = {...}
  local function _17_(...)
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
  return client.call("connect", _17_(...))
end
_2amodule_2a["connect-command"] = connect_command
do local _ = {connect_command, nil} end
local function client_state_command(state_key)
  if a["empty?"](state_key) then
    return a.println(client["state-key"]())
  else
    return client["set-state-key!"](state_key)
  end
end
_2amodule_2a["client-state-command"] = client_state_command
do local _ = {client_state_command, nil} end
local function omnifunc(find_start_3f, base)
  if find_start_3f then
    local _let_19_ = nvim.win_get_cursor(0)
    local row = _let_19_[1]
    local col = _let_19_[2]
    local _let_20_ = nvim.buf_get_lines(0, a.dec(row), row, false)
    local line = _let_20_[1]
    return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
  else
    return eval["completions-sync"](base)
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