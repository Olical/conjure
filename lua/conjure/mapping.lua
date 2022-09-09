local _2afile_2a = "fnl/conjure/mapping.fnl"
local _2amodule_name_2a = "conjure.mapping"
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
local a, bridge, client, config, eval, extract, log, nvim, school, str, _ = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.school"), autoload("conjure.aniseed.string"), nil
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
_2amodule_locals_2a["_"] = _
local function cfg(k)
  return config["get-in"]({"mapping", k})
end
_2amodule_locals_2a["cfg"] = cfg
local function desc(k)
  return config["get-in"]({"desc", k})
end
_2amodule_locals_2a["desc"] = desc
local function vim_repeat(mapping)
  return ("repeat#set(\"" .. nvim.fn.escape(mapping, "\"") .. "\", 1)")
end
_2amodule_locals_2a["vim-repeat"] = vim_repeat
local function buf(mode_or_opts, cmd_suffix, keys, desc0, ...)
  if keys then
    local function _2_(...)
      if ("table" == type(mode_or_opts)) then
        return {a.get(mode_or_opts, "mode"), mode_or_opts}
      else
        return {mode_or_opts, {}}
      end
    end
    local _let_1_ = _2_(...)
    local mode = _let_1_[1]
    local opts = _let_1_[2]
    local args = {...}
    local mapping
    if a["string?"](keys) then
      mapping = (cfg("prefix") .. keys)
    else
      mapping = a.first(keys)
    end
    local cmd = (cmd_suffix and ("Conjure" .. cmd_suffix))
    if cmd then
      nvim.ex.command_(("-range " .. cmd), bridge["viml->lua"](unpack(args)))
    else
    end
    local _5_
    if cmd then
      local function _6_(...)
        if (false ~= a.get(opts, "repeat?")) then
          return (":silent! call " .. vim_repeat(mapping) .. "<cr>")
        else
          return ""
        end
      end
      _5_ = (":" .. cmd .. "<cr>" .. _6_(...))
    else
      _5_ = unpack(args)
    end
    return nvim.buf_set_keymap(0, mode, mapping, _5_, {silent = true, noremap = true, desc = desc0})
  else
    return nil
  end
end
_2amodule_2a["buf"] = buf
local function eval_marked_form()
  local mark = eval["marked-form"]()
  local mapping
  local function _9_(m)
    return ((":ConjureEvalMarkedForm<CR>" == a.get(m, "rhs")) and m.lhs)
  end
  mapping = a.some(_9_, nvim.buf_get_keymap(0, "n"))
  if (mark and mapping) then
    return nvim.ex.silent_("call", vim_repeat((mapping .. mark)))
  else
    return nil
  end
end
_2amodule_2a["eval-marked-form"] = eval_marked_form
local function on_filetype()
  buf("n", "LogSplit", cfg("log_split"), desc("log_split"), "conjure.log", "split")
  buf("n", "LogVSplit", cfg("log_vsplit"), desc("log_vsplit"), "conjure.log", "vsplit")
  buf("n", "LogTab", cfg("log_tab"), desc("log_tab"), "conjure.log", "tab")
  buf("n", "LogBuf", cfg("log_buf"), desc("log_buf"), "conjure.log", "buf")
  buf("n", "LogToggle", cfg("log_toggle"), desc("log_toggle"), "conjure.log", "toggle")
  buf("n", "LogCloseVisible", cfg("log_close_visible"), desc("log_close_visible"), "conjure.log", "close-visible")
  buf("n", "LogResetSoft", cfg("log_reset_soft"), desc("log_reset_soft"), "conjure.log", "reset-soft")
  buf("n", "LogResetHard", cfg("log_reset_hard"), desc("log_reset_hard"), "conjure.log", "reset-hard")
  buf("n", "LogJumpToLatest", cfg("log_jump_to_latest"), desc("log_jump_to_latest"), "conjure.log", "jump-to-latest")
  buf("n", nil, cfg("eval_motion"), desc("eval_motion"), ":set opfunc=ConjureEvalMotion<cr>g@")
  buf("n", "EvalCurrentForm", cfg("eval_current_form"), desc("eval_current_form"), "conjure.eval", "current-form")
  buf("n", "EvalCommentCurrentForm", cfg("eval_comment_current_form"), desc("eval_comment_current_form"), "conjure.eval", "comment-current-form")
  buf("n", "EvalRootForm", cfg("eval_root_form"), desc("eval_root_form"), "conjure.eval", "root-form")
  buf("n", "EvalCommentRootForm", cfg("eval_comment_root_form"), desc("eval_comment_root_form"), "conjure.eval", "comment-root-form")
  buf("n", "EvalWord", cfg("eval_word"), desc("eval_word"), "conjure.eval", "word")
  buf("n", "EvalCommentWord", cfg("eval_comment_word"), desc("eval_comment_word"), "conjure.eval", "comment-word")
  buf("n", "EvalReplaceForm", cfg("eval_replace_form"), desc("eval_replace_form"), "conjure.eval", "replace-form")
  buf({mode = "n", ["repeat?"] = false}, "EvalMarkedForm", cfg("eval_marked_form"), desc("eval_marked_form"), "conjure.mapping", "eval-marked-form")
  buf("n", "EvalFile", cfg("eval_file"), desc("eval_file"), "conjure.eval", "file")
  buf("n", "EvalBuf", cfg("eval_buf"), desc("eval_buf"), "conjure.eval", "buf")
  buf("v", "EvalVisual", cfg("eval_visual"), desc("eval_visual"), "conjure.eval", "selection")
  buf("n", "DocWord", cfg("doc_word"), desc("doc_word"), "conjure.eval", "doc-word")
  buf("n", "DefWord", cfg("def_word"), desc("def_word"), "conjure.eval", "def-word")
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
local function on_exit()
  local function _12_()
    return client["optional-call"]("on-exit")
  end
  return client["each-loaded-client"](_12_)
end
_2amodule_2a["on-exit"] = on_exit
local function on_quit()
  return log["close-hud"]()
end
_2amodule_2a["on-quit"] = on_quit
local function init(filetypes)
  nvim.ex.augroup("conjure_init_filetypes")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
  nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
  nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
  nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
  nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
  nvim.ex.autocmd("ExitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-exit" .. "']()"))
  nvim.ex.autocmd("QuitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-quit" .. "']()"))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init"] = init
local function eval_ranged_command(start, _end, code)
  if ("" == code) then
    return eval.range(a.dec(start), _end)
  else
    return eval.command(code)
  end
end
_2amodule_2a["eval-ranged-command"] = eval_ranged_command
local function connect_command(...)
  local args = {...}
  local function _15_(...)
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
  return client.call("connect", _15_(...))
end
_2amodule_2a["connect-command"] = connect_command
local function client_state_command(state_key)
  if a["empty?"](state_key) then
    return a.println(client["state-key"]())
  else
    return client["set-state-key!"](state_key)
  end
end
_2amodule_2a["client-state-command"] = client_state_command
local function omnifunc(find_start_3f, base)
  if find_start_3f then
    local _let_17_ = nvim.win_get_cursor(0)
    local row = _let_17_[1]
    local col = _let_17_[2]
    local _let_18_ = nvim.buf_get_lines(0, a.dec(row), row, false)
    local line = _let_18_[1]
    return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
  else
    return eval["completions-sync"](base)
  end
end
_2amodule_2a["omnifunc"] = omnifunc
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
local function _20_(_241)
  return eval_ranged_command((_241).line1, (_241).line2, (_241).args)
end
nvim.create_user_command("ConjureEval", _20_, {nargs = "?", range = true})
local function _21_(_241)
  return connect_command(unpack((_241).fargs))
end
nvim.create_user_command("ConjureConnect", _21_, {nargs = "*", range = true, complete = "file"})
local function _22_(_241)
  return client_state_command((_241).args)
end
nvim.create_user_command("ConjureClientState", _22_, {nargs = "?"})
local function _23_()
  return school.start()
end
nvim.create_user_command("ConjureSchool", _23_, {})
return _2amodule_2a